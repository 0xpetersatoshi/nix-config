# peter@zenbook

## Ad-hoc WireGuard client (UniFi Dream Machine)

`default.nix` wires up an **on-demand** WireGuard client — nothing runs at boot. The conf lives age-encrypted in
`modules/home/secrets.yaml` (key `wireguard-udm-conf`) and sops-nix decrypts it at login to
`$XDG_RUNTIME_DIR/wg-udm.conf` (tmpfs, `0400`), so the plaintext key never persists on disk.

Bring it up / down with:

```bash
wg-udm-up      # sudo wg-quick up   $XDG_RUNTIME_DIR/wg-udm.conf
wg             # check the handshake
wg-udm-down    # sudo wg-quick down $XDG_RUNTIME_DIR/wg-udm.conf
```

To add or change the conf: `sops modules/home/secrets.yaml`, edit the `wireguard-udm-conf` block, then `nh os switch`
and re-login (or `systemctl --user restart sops-nix`) so the secret re-materializes.

### `AllowedIPs` — split tunnel vs. full tunnel

This is set in the `[Peer]` section of the conf downloaded from the UDM, and it controls what traffic the tunnel
captures:

- **Split tunnel (usually what you want):** route only home traffic over the VPN, leave everything else on the local
  connection. Set `AllowedIPs` to your home subnet(s), e.g.

  ```ini
  AllowedIPs = 192.168.1.0/24
  ```

- **Full tunnel:** send _all_ traffic through home (e.g. to appear on the home network on untrusted Wi-Fi):

  ```ini
  AllowedIPs = 0.0.0.0/0, ::/0
  ```

### `PersistentKeepalive`

Because the UDM sits behind NAT/a firewall, add this to the `[Peer]` section so the NAT mapping stays open and the
tunnel keeps working after idle periods:

```ini
PersistentKeepalive = 25
```

25 seconds is the standard value. Omit it and the connection may silently stall once the router's NAT entry for the
tunnel expires.
