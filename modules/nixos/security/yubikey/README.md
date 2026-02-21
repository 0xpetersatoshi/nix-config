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

## Polkit + YubiKey (polkit-agent-helper sandboxing)

Starting with polkit 127, the `polkit-agent-helper-1` binary runs inside a systemd
transient service (`polkit-agent-helper@.service`) with aggressive sandboxing. This
breaks `pam_u2f` because `libfido2` needs:

- Access to `/dev/hidraw*` devices (blocked by `PrivateDevices=yes`, `DevicePolicy=strict`)
- `AF_NETLINK` sockets for `libudev` device enumeration (blocked by `RestrictAddressFamilies=AF_UNIX`)
- Read access to `/home` for PAM config (blocked by `ProtectHome=yes`)

When these are blocked, `pam_u2f` silently returns `PAM_AUTHINFO_UNAVAIL`, PAM skips
it, and falls through to password-only auth via `pam_unix`. The YubiKey never blinks.

The fix is a systemd dropin override in `default.nix` that relaxes specific sandboxing
options. This is functionally equivalent to how polkit < 127 ran (plain setuid, no
systemd sandboxing). Prior to polkit 127 this was the standard security posture.

If YubiKey stops working with polkit after a nixpkgs update, check if the upstream
`polkit-agent-helper@.service` has changed its sandboxing options.

## Resources

- [PAM U2F Docs](https://developers.yubico.com/pam-u2f/)
- [Yubikey NixOS Guide](https://joinemm.dev/blog/yubikey-nixos-guide)
- [NixOS Wiki: Yubikey](https://nixos.wiki/wiki/Yubikey)
