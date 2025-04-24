# Scripts

## Boot Recovery Script for Multi-Boot System

This script automatically repairs your boot configuration when Windows updates overwrite your boot settings. It's
designed for systems with:

- NixOS (BTRFS on LUKS)
- Arch Linux
- Windows 11

The script reinstalls systemd-boot and fixes the EFI boot order to ensure your system boots to the systemd-boot menu
instead of directly to Windows.

Prerequisites:

- A Linux live USB (NixOS, Arch, or any Linux distribution)

## Verification Checks

After running the script and rebooting, verify the following:

```bash
sudo efibootmgr -v
```

Verify that "Linux Boot Manager" is first in the boot order.

Check Boot Entries:

```bash
ls -al /boot/loader/entries
```
