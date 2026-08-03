# Framework Laptop 13 Pro (`framework`)

Framework Laptop 13 Pro — Intel Core Ultra X7 358H (Panther Lake), 32GB LPCAMM2, Xe3 iGPU, Intel BE211 Wi-Fi 7.

This host is a **drive transplant**: the NVMe SSD is moved over from the zenbook with its NixOS install, LUKS container,
`/home`, sops/age keys, sbctl Secure Boot keys, and this repo intact. Nothing on the disk is wiped.
`hardware-configuration.nix` is a copy of zenbook's because the filesystem and LUKS UUIDs belong to the disk, not the
laptop.

Hardware quirks (fwupd, fprintd, power tuning, ectool, >= 6.17 kernel floor) come from
`nixos-hardware.nixosModules.framework-intel-core-ultra-series3`, imported in `default.nix`.

## How the repo gets onto the machine

It's already there. The repo lives at `~/nix-config` on the drive being transplanted, and the SSH keys used to pull/push
travel with `/home` too. The only requirement is that this branch is committed (and ideally pushed to
`git@github.com:0xpetersatoshi/nix-config`) **before** the swap, so the on-disk checkout contains the `framework` host.
If you forget to push, nothing is lost — the commits are on the disk; pushing can wait.

## Before the swap (on the zenbook)

1. Commit and push this repo so the drive carries the `framework` host:

   ```bash
   cd ~/nix-config && git add -A && git commit && git push
   ```

2. (Optional, recommended) Pre-build the framework system so the post-swap switch needs no network:

   ```bash
   nix build ~/nix-config#nixosConfigurations.framework.config.system.build.toplevel
   ```

3. Power off, move the SSD into the Framework.

## Install day (on the Framework)

1. **BIOS (F2 at boot): disable Secure Boot** for the first boot. The Framework's firmware doesn't know our sbctl keys
   yet, so it would refuse the lanzaboote-signed images.

2. **Boot.** The fallback loader on the ESP (`EFI/BOOT/BOOTX64.EFI`) should be picked up automatically; if not, use the
   one-time boot menu (F12) or "boot from file" in the BIOS and select it. TPM2 auto-unlock will fail — the old
   enrollment is bound to the zenbook's TPM — and fall back to the LUKS passphrase prompt. This is expected; type the
   passphrase.

3. **Switch to the framework config.** The machine comes up as "zenbook"; `nh` picks the host by hostname, so name it
   explicitly:

   ```bash
   export FLAKE=~/nix-config
   nh os switch -H framework
   # or: sudo nixos-rebuild switch --flake ~/nix-config#framework
   reboot
   ```

4. **Enroll Secure Boot keys.** The keys are already on disk at `/var/lib/sbctl`. Reboot into BIOS, put Secure Boot into
   **setup mode** (clear/delete the factory keys), boot, then:

   ```bash
   sudo sbctl enroll-keys --microsoft
   sudo sbctl verify   # everything should be signed
   ```

   Reboot into BIOS again and **re-enable Secure Boot**. Confirm with `bootctl status` (Secure Boot: enabled).

5. **Re-enroll TPM2 LUKS unlock — only after Secure Boot is final.** PCR 7 measures Secure Boot state, so enrolling
   earlier would break auto-unlock on the next boot. `luksCryptenroller` wipes the stale zenbook enrollment and creates
   the new one:

   ```bash
   sudo luksCryptenroller
   reboot   # should unlock without a passphrase
   ```

6. **Update BIOS/firmware** (never via GUI updaters, per Framework):

   ```bash
   sudo fwupdmgr refresh && sudo fwupdmgr update
   ```

7. **Enroll fingerprints** (fprintd is enabled by the hardware module):

   ```bash
   fprintd-enroll
   ```

## Post-install checks

```bash
bootctl status                    # Secure Boot: enabled, lanzaboote entries
sudo systemd-cryptenroll /dev/disk/by-uuid/24dd164a-9843-4e7d-8645-6efccaa7043f
                                  # slots: password + tpm2
sudo sbctl verify                 # all files signed
nmcli radio wifi                  # BE211 Wi-Fi up
powerprofilesctl                  # power-profiles-daemon active (not TLP)
vainfo                            # iHD media driver on Xe3
```

Leave `stateVersion` at `"24.11"` (system and home) — it tracks when the install was born, which was on the zenbook.

## Rescue: machine won't boot / starting from a blank state

If the transplanted drive won't boot, or this ever needs to be installed onto a fresh disk:

1. Boot a NixOS installer ISO (graphical or minimal) from USB, with Secure Boot disabled.

2. To repair the existing install, unlock and mount it, then re-run the bootloader install from inside:

   ```bash
   sudo cryptsetup open /dev/disk/by-uuid/24dd164a-9843-4e7d-8645-6efccaa7043f nixos-root
   sudo mount -o subvol=root /dev/mapper/nixos-root /mnt
   sudo mount -o subvol=home /dev/mapper/nixos-root /mnt/home
   sudo mount -o subvol=nix  /dev/mapper/nixos-root /mnt/nix
   sudo mount /dev/disk/by-uuid/1F06-BFA6 /mnt/boot
   sudo nixos-enter --root /mnt
   # inside: nixos-rebuild boot --flake /home/peter/nix-config#framework
   ```

3. For a genuinely fresh disk (no data to keep), clone the repo over HTTPS (the ISO has no SSH keys), bring back a disko
   layout for the new drive (see `systems/x86_64-linux/nixbox/disks.nix` for the pattern this host used before the
   transplant plan), partition with disko, then:

   ```bash
   git clone https://github.com/0xpetersatoshi/nix-config
   sudo nixos-install --flake ./nix-config#framework
   ```

   A fresh install also needs `hardware-configuration.nix` regenerated
   (`nixos-generate-config --no-filesystems --root /mnt`), new sops/age keys or a restored `/home`, and `stateVersion`
   bumped to the current release.
