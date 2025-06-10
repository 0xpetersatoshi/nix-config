# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains a comprehensive Nix configuration for managing multiple systems:
- NixOS for Linux systems
- nix-darwin for macOS systems
- home-manager for user-level configuration across all platforms

The repository is built using the [Snowfall](https://github.com/snowfallorg/lib) framework, which provides a modular approach to Nix configuration.

## Key Commands

### Building and Applying Configurations

For NixOS systems:
```bash
# Set the FLAKE environment variable to the path of the nix config
export FLAKE=/home/peter/nix-config/

# Apply system configuration
nh os switch
```

For Linux systems with home-manager only:
```bash
export FLAKE=/home/peter/nix-config/
nh home switch
```

For macOS systems:
```bash
# First time setup
nix run nix-darwin -- switch --flake .

# Regular updates
darwin-rebuild switch --flake .
```

### Updating Dependencies

Update the flake.lock file without applying changes:
```bash
nix flake update
```

Then apply the changes with the appropriate rebuild command.

### Disk Partitioning with Disko

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./path/to/disko.nix
```

## Repository Structure

- `systems/` - System-level configurations for different machines
  - `aarch64-darwin/` - macOS systems
  - `x86_64-linux/` - Linux systems
- `homes/` - User-level configurations for different users and machines
- `modules/` - Reusable configuration modules
  - `nixos/` - NixOS-specific modules
  - `darwin/` - macOS-specific modules
  - `home/` - Cross-platform user modules
- `lib/` - Helper functions for the configuration
- `dotfiles/` - Configuration files for various programs
- `overlays/` - Nix overlays for package customizations
- `packages/` - Custom packages
- `scripts/` - Utility scripts
- `themes/` - System theme configurations
- `wallpaper/` - Wallpaper images

## Architecture Patterns

- **Flakes** - Uses Nix Flakes for reproducible builds and dependency management
- **Roles** - Leverages "roles" as composable configuration groups (common, desktop, development, gaming)
- **Modular Design** - Organizes configurations into reusable modules
- **System-specific Configurations** - Configurations organized by system architecture and hostname
- **Secure Boot** - Includes secure boot support via Lanzaboote
- **Secrets Management** - Uses sops-nix for managing secrets
- **Desktop Environments** - Configurations for multiple desktop environments:
  - Hyprland - Highly customized with keybindings, window rules, and monitors config
  - KDE, GNOME - Alternative desktop environments

## Common Modifications

### Adding a New System

1. Create a new directory under `systems/` for the system architecture and hostname
2. Create a `default.nix` file with the system configuration
3. Optionally create a `hardware-configuration.nix` file for hardware-specific settings
4. For NixOS systems, optionally create a `disks.nix` file for disk partitioning with Disko

### Modifying Hyprland Configuration

1. Edit files in `modules/home/desktops/hyprland/`:
   - `config.nix` - General Hyprland settings
   - `keybindings.nix` - Keyboard shortcuts
   - `windowrules.nix` - Application-specific rules
   - `monitors.nix` - Multi-monitor configuration

### Modifying Keyboard Layout with Kanata

Edit the appropriate file in `dotfiles/kanata/`:
- `config.kbd` - General configuration
- `linux.config.kbd` - Linux-specific configuration

## Security Features

- **Secure Boot** - Configured via Lanzaboote
- **Secrets Management** - Using sops-nix
- **TPM Support** - For hardware-backed security
- **YubiKey Integration** - For 2FA and GPG keys