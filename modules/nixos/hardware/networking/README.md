# Networking notes

## Captive portal unreachable: Docker subnet collision (2026-09)

### Symptom

On hotel Wi-Fi with a captive portal, the framework laptop associated and got a DHCP lease, but the portal never
triggered. Every page — including `http://neverssl.com` and the gateway IP itself (`http://172.20.0.1`) — failed with
DNS/connection errors. Disabling Tailscale, DNSSEC, and DNSOverTLS, and pointing `resolvectl dns wlan0` at the gateway
changed nothing. iOS devices and a travel router on the same Wi-Fi worked fine.

### Root cause

Not DNS — routing. A Docker compose bridge owned `172.20.0.0/16` with the laptop itself holding `172.20.0.1`:

```
172.20.0.0/16 dev br-86b51f5ca68e proto kernel scope link src 172.20.0.1
```

The hotel handed out a lease in `172.20.x.x` with gateway/DNS at `172.20.0.1`. The kernel's directly-connected bridge
route shadowed the hotel subnet, so all traffic to the gateway (DNS queries, the portal redirect) was delivered to the
local Docker bridge and blackholed. Docker's default pools cover `172.17.0.0/16`–`172.30.x`, which overlaps common
hotel/venue ranges.

Note: a bridge marked `linkdown` can still shadow the route (`ignore_routes_with_linkdown` defaults to 0), so merely
having the compose network _defined_ is enough to collide.

### Permanent fix (applied)

`modules/nixos/services/virtualisation/docker/default.nix` pins Docker to ranges venues never use:

- `bip = "10.212.0.1/24"` (docker0)
- `default-address-pools = [{ base = "10.213.0.0/16"; size = 24; }]` (compose networks)

Existing networks keep their old subnets until recreated:

```bash
docker compose down && docker network prune && docker compose up -d
```

### If it re-emerges (emergency fix on-site)

1. Find the collision: `ip route | grep "$(ip route | awk '/default/{print $3}' | cut -d. -f1-2)"` — look for a
   `br-*`/`docker0` route covering the Wi-Fi gateway's subnet.
2. Delete the bridge: `sudo ip link del br-XXXX` (Docker recreates it on the next `compose up`). Deleting beats
   `ip link set down` — see linkdown note above.
3. Retry `http://neverssl.com` to trigger the portal.

Also possible with other virtual networks (libvirt `virbr0` on `192.168.122.0/24`, podman on `10.88.0.0/16`) — same
diagnosis, same fix.
