# Yubikey

## Configure Yubikey for sudo access

1. Connect your Yubikey

2. Create an authorization mapping file for your user. The authorization mapping file is like `~/.ssh/known_hosts` but
   for Yubikeys.

```bash
nix-shell -p pam_u2f
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
add another yubikey (optional): pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

3. Verify that `~/.config/Yubico/u2f_keys` contains one line in the following style:

<username>:<KeyHandle1>,<UserKey1>,<CoseType1>,<Options1>:<KeyHandle2>,<UserKey2>,<CoseType2>,<Options2>:...

4. Enable the u2f PAM module for login and sudo requests

```nix
security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
};
```

[PAM U2F Docs](https://developers.yubico.com/pam-u2f/)

5. Verify PAM configuration by running a `sudo` command and touching the Yubikey to authenticate

Follow [this guide](https://nixos.wiki/wiki/Yubikey) for more info.
