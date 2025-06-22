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
  - [Updating](#updating)
- [Resources](#resources)
<!--toc:end-->

## Getting Started

Install nix (preferably) using the [Determinate Systems Installer](https://github.com/DeterminateSystems/nix-installer).

If running on MacOS, you'll need `nix-darwin` which won't initially be installed. Instructions for that are included
in the next section.

### Installation Methods

#### Using nixos-anywhere

> **NOTE**: The architecture of the target machine must match the architecture of the local machine for this option.

1. Use netboot or the nix usb installer to initiate the installer on the target machine
2. Run `passwd` to create new password for the installer user
3. Copy public ssh keys to the installer user

```{bash}
mkdir -p ~/.ssh
curl https://github.com/0xpetersatoshi.keys >> ~/.ssh/authorized_keys
```

4. Note the IP address of the target machine using `ip addr`
5. Test connection from local machine:

```{bash}
ssh -i ~/.ssh/vms.pub -v nixos@<ip>
```

6. Run:

```{bash}
nix run github:nix-community/nixos-anywhere -- --flake '.#<HOSTNAME>' -i ~/.ssh/vms.pub --target-host nixos@<IP_ADDRESS>
```

#### Using Nix on the Target Machine Directly

On NixOS:

```bash
# New machine without git
nix-shell -p git

git clone https://github.com/0xpetersatoshi/nix-config.git
cd nix-config

sudo nixos-install --flake .#<hostname>
```

On MacOS:

```bash
# On the first run, you'll need to install nix-darwin
nix run nix-darwin -- switch --flake .

# On subsequent runs, just run
darwin-rebuild switch --flake .

```

### Configuring Disk Partitioning on NixOS using Disko

You can optionally use [disko](https://github.com/nix-community/disko/blob/master/docs/quickstart.md) to configure the disk
partitioning by running:

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

> _NOTE_: when using the [nh](https://github.com/viperML/nh) tool, set the `FLAKE` env var to the path of the nix config (i.e. `/home/peter/nix-config/`)

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

## Resources

I drew heavy inspiration from the following repos:

- [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix)
- [hmajid2301/nixicle](https://gitlab.com/hmajid2301/nixicle)
- [usmcamp0811/dotfiles](https://gitlab.com/usmcamp0811/dotfiles)
