# Home Modules

## Sops

### Configure a sops file

First, make sure to add the sops filepath to the [.sops.yaml](../../.sops.yaml) file. Then, to configure the file, run:

```bash
sops path/to/secrets.yaml
```

### Troubleshooting

If after rebuilding the nix configuration you see an error like this:

```bash
warning: the following units failed: home-manager-peter.service
Error:
   0: Activation (test) failed
   1: Activating configuration (exit status Exited(4))

Location:
   src/commands.rs:544
```

Check the sops.nix service with this command:

```bash
journalctl --user -u sops-nix.service -n 50 --no-pager
```

If you see the following error:

```bash
Nov 27 19:41:45 zenbook wn1rg49kfh40lwjb8gpcca15x5pq8gp9-sops-nix-user[822532]: /nix/store/ak83svgknfsqvag73f03z0hs84lcnphc-sops-install-secrets-0.0.1/bin/sops-install-secrets: failed to decrypt '/nix/store/m76lff5kiq6hr6r83w4kmglgwy4avhc9-9n44p16lkgskiyjyp9yd1smwvhly0m27-source/modules/home/secrets.yaml': Error getting data key: 0 successful groups required, got 0
Nov 27 19:41:45 zenbook systemd[4345]: sops-nix.service: Main process exited, code=exited, status=1/FAILURE
Nov 27 19:41:45 zenbook systemd[4345]: sops-nix.service: Failed with result 'exit-code'.
Nov 27 19:41:45 zenbook systemd[4345]: Failed to start sops-nix activation.
```

That means you need to unlock the yubikey being used to encrypt/decrypt the secrets file. The simplest way to do this is to run:

```bash
sops path/to/secrets.yaml
```

This will prompt you to enter your PIN to unlock the yubikey. Try applying the nix configuration again after this and it should succeed.
