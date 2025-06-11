# OpenCode.md

## Build/Test Commands
```bash
# Set environment variable for nh tool
export FLAKE=/home/peter/nix-config/

# Apply NixOS system configuration
nh os switch

# Apply home-manager configuration (Linux)
nh home switch

# Apply macOS configuration
darwin-rebuild switch --flake .

# Update flake dependencies
nix flake update

# Check flake for errors
nix flake check

# Format Nix code
alejandra .

# Test specific system configuration
nix build .#nixosConfigurations.nixbox.config.system.build.toplevel
```

## Code Style Guidelines

### Nix Files
- Use 2-space indentation consistently
- Follow Snowfall lib conventions with namespace "igloo"
- Import order: `{pkgs, config, lib, namespace, ...}:` 
- Use `with lib; with lib.${namespace};` pattern for library functions
- Prefer `mkIf cfg.enable` for conditional configuration
- Use `mkBoolOpt`, `mkOpt` for options with sensible defaults
- File structure: options first, then config block
- Use descriptive variable names: `cfg = config.cli.programs.git`

### Shell Scripts
- Use `#!/usr/bin/env sh` shebang
- Quote variables: `"$VARIABLE"` not `$VARIABLE`
- Use `case` statements for multiple conditions
- Exit early on errors with proper exit codes

### Module Organization
- Group related functionality in roles (common, desktop, development, gaming)
- Use enable flags for all optional features
- Follow directory structure: `modules/{nixos,darwin,home}/category/program/`
- Keep hardware-specific config in separate files