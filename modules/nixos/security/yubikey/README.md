# Yubikey U2F Configuration Guide

## Generate Yubkiey authorization mappings

```bash
nix-shell -p pam_u2f

# For each key, run:
pamu2fcfg -n -o pam://yubi

# Save the output for later use in yubikey.nix module
```

## Enable the u2f PAM module for login and sudo requests

```nix
security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
};
```

## Resources

- [PAM U2F Docs](https://developers.yubico.com/pam-u2f/)
- [Yubikey NixOS Guide](https://joinemm.dev/blog/yubikey-nixos-guide)
- [NixOS Wiki: Yubikey](https://nixos.wiki/wiki/Yubikey)
