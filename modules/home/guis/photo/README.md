# ON1 Photo RAW on NixOS (via Lutris + GE-Proton)

ON1 Photo RAW is a Windows/macOS-only photo editor. It runs on Linux under Wine/GE-Proton, managed by Lutris. This
documents the exact steps used to get it working on `nixbox` (AMD RX 9070 XT), so it can be recreated elsewhere.

Most of the work is **imperative, one-time runtime setup inside Lutris** — it cannot be expressed declaratively in Nix
(proprietary installer, Wine prefix state, .NET, GUI dialogs). Nix only provides the tooling.

Reference write-up this is based on: <https://code.mendhak.com/on1-photo-raw-linux/>

---

## 1. Nix config (the only declarative part)

Add to the machine's home config (see `homes/x86_64-linux/peter@nixbox/default.nix`):

```nix
home.packages = with pkgs; [
  lutris       # manages the Wine prefix + GE-Proton runner
  protonup-qt  # downloads GE-Proton builds into ~/.local/share
];
```

Lutris is self-contained (FHS-wrapped, bundles its own wine/winetricks), so it does **not** depend on the `roles.gaming`
module. It does need working Vulkan:

- **AMD:** `hardware.graphics.enable = true` + `enable32Bit = true` (provided by the `hardware.drivers` module with
  `hasAmdGpu = true`). RADV (Mesa Vulkan) works out of the box — `hardware.drivers.vulkanEnabled` is only needed for
  extra vulkan tooling, not for running the app.
- Other GPUs: ensure 32-bit Vulkan is available for that vendor.

Apply with `nh home switch` (with `FLAKE` set).

> Harmless log noise on NixOS: Lutris prints `['/usr/bin/vulkaninfo'] ... No such file or directory`. It probes a
> non-Nix path; RADV still works. Ignore it.

---

## 2. Files to download first

| File                          | Source                                                        | Notes                                                   |
| ----------------------------- | ------------------------------------------------------------- | ------------------------------------------------------- |
| `ON1_Photo_RAW_2026.exe`      | ON1 account / website                                         | The installer (~900 MB)                                 |
| `NDP48-x86-x64-AllOS-ENU.exe` | Microsoft ".NET Framework 4.8 offline installer" support page | Fallback only; `winetricks dotnet48` usually fetches it |
| `WinMetadata.zip`             | <https://archive.org/download/win-metadata/WinMetadata.zip>   | WinRT metadata, required or ON1 renders all-dark        |

Save them anywhere (e.g. `~/Documents/installers/`). Location doesn't matter; what matters is where they end up **inside
the Wine prefix** (below).

---

## 3. Runtime setup in Lutris (one time)

### 3.1 Install the GE-Proton runner

- Launch `protonup-qt`, add **GE-Proton (latest, e.g. GE-Proton11-3)**. It installs into
  `~/.local/share/lutris/runners/...`. GE-Proton10-34 is the known-good fallback if the latest misbehaves.

### 3.2 Create the Lutris game entry

- Lutris → `+` → **Install a Windows game from an executable**.
- Source file: the `ON1_Photo_RAW_2026.exe`.
- **Installer preset: Windows 11.**
- This creates the 64-bit prefix (on nixbox: `/home/peter/Apps/on1-photo-raw`). Let it finish creating the prefix. **Do
  not** rely on this step to actually install ON1 — see §3.6.

### 3.3 Runner options

Right-click ON1 → Configure → **Runner options**:

- **Enable DXVK** — on
- **Enable D3D Extras (VKD3D)** — on
- Leave the anti-cheat / FSR / Esync toggles as default (irrelevant here).
- `Use system winetricks` — **off** (use Lutris's bundled winetricks).

### 3.4 winetricks components

Wine tools menu (utilities icon bottom-left, next to Play) → **Winetricks** → _Select the default wineprefix_:

- **Install a Windows DLL or component:** `vcrun2022`, `dotnet48`
- **Install a font:** `corefonts`, `tahoma`

`dotnet48` throws a couple of benign error dialogs and is slow — let it finish. Verify success later via
`<prefix>/winetricks.log` and the presence of real `clr.dll`/`mscorlib.dll` under
`<prefix>/drive_c/windows/Microsoft.NET/Framework64/v4.0.30319/`.

### 3.5 ⚠️ Reset Windows version to 11 (critical gotcha)

`dotnet48` **forces the prefix to Windows 7 and leaves it there**, overriding the win11 preset. The ON1 installer then
refuses to run ("Windows 7 not supported"). Fix after running dotnet48:

Easiest: Wine tools → **Wine configuration (winecfg)** → Applications tab → Windows Version → **Windows 11** → Apply.

If winecfg/`winetricks win11` don't stick (can happen with GE-Proton/umu prefixes), edit `<prefix>/system.reg` directly
**while no wine process is running**. In both `[Software\\Microsoft\\Windows NT\\CurrentVersion]` and
`[Software\\Wow6432Node\\Microsoft\\Windows NT\\CurrentVersion]` set:

```txt
"CSDVersion"=""
"CurrentBuild"="22000"
"CurrentBuildNumber"="22000"
"CurrentMajorVersionNumber"=dword:0000000a
"CurrentMinorVersionNumber"=dword:00000000
"CurrentVersion"="6.3"
"ProductName"="Microsoft Windows 11"
```

And in `[System\\ControlSet001\\Control\\Windows]` set `"CSDVersion"=dword:00000000`.

Confirm no wineserver is running first (`pgrep -af wineserver`) or the edit gets overwritten on shutdown.

### 3.6 Actually install ON1 into the prefix

The "install from executable" flow only prepped the prefix — it does **not** install ON1. Install it into the _existing_
prepped prefix:

- Wine tools → **Open Bash terminal** (opens with the right `WINEPREFIX` + GE-Proton), then:

  ```bash
  wine ~/Documents/installers/ON1_Photo_RAW_2026.exe
  ```

  (or Wine tools → _Run EXE inside wine prefix_ → Ctrl+L to type the path, since the file picker filters `.exe` out of
  the list.)

- Click through the ON1 installer to **Finish**.

Note: ON1's installer defaults to drive **`X:`**, which Wine maps to your home dir — so the app installs to
`~/ON1/ON1 Photo RAW 2026/`, **outside** the Wine prefix. That's fine; don't delete `~/ON1` thinking it's stray.

### 3.7 Extract WinMetadata

Extract the `.winmd` files into the prefix:

```bash
unzip -j -o WinMetadata.zip -d "/home/peter/Apps/on1-photo-raw/drive_c/windows/system32/WinMetadata"
```

### 3.8 ⚠️ Point Lutris at the installed exe (persistence fix)

The Lutris entry still has **no executable set**, so it works only in the session you installed it and then fails on
restart with `MissingGameExecutableError: This game has no executable set`. Fix it (with Lutris running, so it saves —
never edit its config files while it's open):

- Right-click ON1 → **Configure** → **Game options** → **Executable**, paste (type it; the browser hides the file):

  ```txt
  /home/peter/ON1/ON1 Photo RAW 2026/ON1 Photo RAW 2026.exe
  ```

- Confirm **Wine prefix** = `/home/peter/Apps/on1-photo-raw`.
- **Save.**

Now it launches from the library and persists across restarts.

---

## Gotchas summary

1. `dotnet48` silently downgrades the prefix to **Windows 7** → reset to Windows 11 (§3.5) or the ON1 installer refuses
   to run.
2. Lutris "install from executable" **doesn't set the game exe** → set it manually in Game options (§3.8), or it breaks
   on next launch.
3. ON1 installs to drive `X:` = `~/ON1/...`, outside the prefix.
4. `.NET 4.8` is mandatory — without it ON1's window is all-dark.
5. `WinMetadata` is mandatory (WinRT).
6. Never edit Lutris/wine config files while Lutris or a wineserver is running.
7. The `/usr/bin/vulkaninfo` error in Lutris logs is harmless on NixOS.

## Machine-specific paths (nixbox)

- Wine prefix: `/home/peter/Apps/on1-photo-raw`
- Installed app: `/home/peter/ON1/ON1 Photo RAW 2026/ON1 Photo RAW 2026.exe`
- On another machine these differ; check the prefix set in Lutris Game options and the Start Menu `.lnk` target
  (`drive_c/users/steamuser/AppData/Roaming/ Microsoft/Windows/Start Menu/Programs/ON1/`) to find the real exe.
