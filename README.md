<h3 align="center">
 <img src="https://nixos.org/logo/nixos-logo-only-hires.png" height="20" /> NixOS Config for <a href="https://github.com/0xpetersatoshi">0xpetersatoshi</a>
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

## Getting Started

Install nix (preferably) using the [Determinate Systems Installer](https://github.com/DeterminateSystems/nix-installer).

If running on MacOS, you'll need `nix-darwin` which won't initially be installed. Instructions for that are included
in the next section.

### Installing

```bash
# New machine without git
nix-shell -p git

# Clone
git clone https://github.com/0xpetersatoshi/dotfiles.git
cd dotfiles

# Linux
sudo nixos-rebuild switch --flake .

 # MacOS
# On the first run, you'll need to install nix-darwin
nix run nix-darwin -- switch --flake .

# On subsequent runs, just run
darwin-rebuild switch --flake .

```

### Updating

```bash
# This only updates the `flake.lock` file but does not apply the changes
nix flake update

# Run nixos-rebuild or darwin-rebuild to apply the changes
darwin-rebuild switch --flake .
```

## Resources

I drew heavy inspiration from the following repos:

- [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix)
- [hmajid2301/nixicle](https://gitlab.com/hmajid2301/nixicle)
