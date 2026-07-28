<h3 align="center">
 <img src="https://nixos.org/logo/nixos-logo-only-hires.png" height="20" /> Nix Config for <a href="https://github.com/0xpetersatoshi">0xpetersatoshi</a>
</h3>

<p align="center">
 <a href="https://github.com/0xpetersatoshi/dotfiles/commits"><img src="https://img.shields.io/github/last-commit/0xpetersatoshi/dotfiles?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
  <a href="https://wiki.nixos.org/wiki/Flakes" target="_blank">
 <img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge">
</a>
<a href="https://github.com/snowfallorg/lib" target="_blank">
 <img alt="Built With Snowfall" src="https://img.shields.io/static/v1?logoColor=d8dee9&label=Built%20With&labelColor=5e81ac&message=Snowfall&color=d8dee9&style=for-the-badge">
</a>
</p>

My NixOS, Darwin, and Nix Home Manager Config.

<!--toc:start-->

- [Getting Started](#getting-started)
  - [Installation Methods](#installation-methods)
    - [Using nixos-anywhere](#using-nixos-anywhere)
    - [Using Nix on the Target Machine Directly](#using-nix-on-the-target-machine-directly)
  - [Configuring Disk Partitioning on NixOS using Disko](#configuring-disk-partitioning-on-nixos-using-disko)
- [Usage](#usage)
  - [Applying latest home-manager or nixos configuration](#applying-latest-home-manager-or-nixos-configuration)
  - [Deploying to a Remote Machine over SSH](#deploying-to-a-remote-machine-over-ssh)
  - [Updating](#updating)
- [Helpful Commands](#helpful-commands)
  - [Getting sha256 artifact hashes](#getting-sha256-artifact-hashes)
- [Resources](#resources)
<!--toc:end-->

## Getting Started

### Installation Methods

#### Using nixos-anywhere

> [!warning] [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) is for **initial installs only**. It runs
> disko in `destroy,format,mount` mode, wiping the target's disks before installing. To update a machine that is already
> running NixOS, see [Deploying to a Remote Machine over SSH](#deploying-to-a-remote-machine-over-ssh) instead.

1. Use netboot or the nix usb installer to initiate the installer on the target machine
2. Run `passwd` to create new password for the installer user
3. Copy public ssh keys to the installer user:

   ```bash
   mkdir -p ~/.ssh
   curl https://github.com/0xpetersatoshi.keys >> ~/.ssh/authorized_keys
   ```

4. Note the IP address of the target machine using `ip addr`
5. Test connection from local machine:

   > [!important] If using the 1password ssh agent, using `<ssh-key-name>.pub` will work here. Otherwise, you will need
   > to reference the actual ssh private key.

   ```bash
   ssh -i ~/.ssh/vms.pub -v nixos@<ip>
   ```

6. Run:

   ```bash
   nix run github:nix-community/nixos-anywhere -- --flake '.#<HOSTNAME>' -i ~/.ssh/vms --target-host nixos@<IP_ADDRESS>
   ```

Useful flags:

- `--build-on remote` — build on the target machine instead of locally. Use this when the target's architecture does not
  match the local machine (e.g. deploying to an x86_64 server from an aarch64 Mac).
- `--generate-hardware-config nixos-generate-config ./systems/<arch>/<hostname>/hardware-configuration.nix` — generate
  the hardware config from the target during install instead of writing it by hand.
- `--vm-test` — run the install in a local VM first to validate the configuration without touching the target.

#### Using Nix on the Target Machine Directly

On NixOS:

```bash
# New machine without git
nix-shell -p git

git clone https://github.com/0xpetersatoshi/nix-config.git
cd nix-config

sudo nixos-install --flake .#<hostname>
```

> [!note] If you run into an error about the disk running out of space, set `TMPDIR=/mnt/flake/tmp` (or any other path
> on the disk you are installing nix onto).

On MacOS:

1. Install nix (preferably) using the
   [Determinate Systems Installer](https://github.com/DeterminateSystems/nix-installer).
2. Make sure [homebrew](https://brew.sh/) is installed.
3. Make sure your hostname is set to match the target hostname from the [homes](./homes/) directory. If it is not, run:

```{bash}
sudo scutil --set HostName <name>
sudo scutil --set LocalHostName <name>
sudo scutil --set ComputerName <name>
```

```bash
# On the first run, you'll need to install nix-darwin
sudo --preserve-env=HOME nix run nix-darwin -- switch --flake .

# On subsequent runs, just run
nh darwin switch

```

### Configuring Disk Partitioning on NixOS using Disko

You can optionally use [disko](https://github.com/nix-community/disko/blob/master/docs/quickstart.md) to configure the
disk partitioning by running:

```{bash}
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./path/to/disko.nix
```

Then, to verify successful configuration, you can run the following commands:

```{bash}
mount | grep /mnt
```

```{bash}
sudo fdisk -l /dev/sda
```

## Usage

### Applying latest home-manager or nixos configuration

> _NOTE_: when using the [nh](https://github.com/viperML/nh) tool, set the `FLAKE` env var to the path of the nix config
> (i.e. `/home/peter/nix-config/`)

On NixOS:

```bash
nh os switch
```

On Linux:

```bash
nh home switch
```

On MacOS:

```bash
darwin-rebuild switch --flake .
```

### Deploying to a Remote Machine over SSH

For machines that are **already running NixOS** (do not use nixos-anywhere for this — it wipes the target's disks),
build the configuration locally and push it over ssh with `nh`:

```bash
# Builds locally, copies the closure to the target, and activates it remotely.
# --hostname defaults to the target machine's hostname, so it can usually be omitted.
nh os switch --hostname appbox --target-host peter@appbox --elevation-strategy passwordless
```

Requirements on the target:

- ssh key access for the deploying user (configured by the ssh module for all systems with `roles.server` enabled)
- passwordless sudo for activation (the server role sets `security.sudo.wheelNeedsPassword = false`); this is what
  `--elevation-strategy passwordless` relies on — without the flag, nh tries to prompt for a sudo password, which
  fails with "The input device is not a TTY" in non-interactive shells

Alternatively, plain `nixos-rebuild` works too:

```bash
nixos-rebuild switch --flake .#appbox --target-host peter@appbox --sudo
```

If the target's architecture differs from the local machine, add `--build-host peter@appbox` (nh) or `--build-on remote`
style remote building so the build happens on the target.

### Updating

```bash
# This only updates the `flake.lock` file but does not apply the changes
nix flake update

# Run nixos-rebuild or darwin-rebuild to apply the changes
darwin-rebuild switch --flake .

# on NixOS
# nh os switch
```

## Helpful Commands

### Getting sha256 artifact hashes

```bash
nix-prefetch-url https://registry.npmjs.org/@nomicfoundation/slang/-/slang-1.0.0.tgz
# output: 1hvf7s7kd4881xi929i1in9j5dmk37xhmx5zamczni2nvk1c8lxd

nix hash convert --hash-algo sha256 1hvf7s7kd4881xi929i1in9j5dmk37xhmx5zamczni2nvk1c8lxd
# output: sha256-rVPEwtxWRPtZVb/0CvsZs7Yik40hJpFiDwiRNo8+bsM=
```

### Generating nix hardware-configuration.nix file

```bash
nixos-generate-config --root /mnt
```

### Hyprland

Setting monitor scale and resolution:

```bash
hyprctl keyword monitor "eDP-1, highrr, auto, 1.25"
```

## Resources

### Flake

I drew heavy inspiration from the following repos:

- [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix)
- [hmajid2301/nixicle](https://gitlab.com/hmajid2301/nixicle)
- [usmcamp0811/dotfiles](https://gitlab.com/usmcamp0811/dotfiles)

### NixOS

- [Configuring Hardware Acceleration for Video](https://wiki.nixos.org/wiki/Accelerated_Video_Playback)
