#!/bin/bash
# fix-boot.sh - Automated boot recovery script for multi-boot system with NixOS, Arch, and Windows
# Save this script and run it from a live USB environment when Windows breaks your boot configuration

set -e  # Exit on error
set -x  # Print commands for debugging

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo $0'"
    exit 1
fi

# Define partitions (adjust these to match your system)
EFI_PARTITION="/dev/nvme0n1p1"
NIXOS_PARTITION="/dev/nvme0n1p5"
ARCH_PARTITION="/dev/nvme0n1p6"

# Create mount points
mkdir -p /tmp/fix-boot/mnt
mkdir -p /tmp/btrfs_root

# Step 1: Unlock LUKS partition if encrypted
echo "Unlocking LUKS partition..."
cryptsetup luksOpen $NIXOS_PARTITION nixos-root

# Step 2: Mount BTRFS root to identify subvolumes
mount -o subvolid=5 /dev/mapper/nixos-root /tmp/btrfs_root
echo "Available BTRFS subvolumes:"
btrfs subvolume list /tmp/btrfs_root

# Step 3: Mount the root subvolume
mount -o subvol=root /dev/mapper/nixos-root /tmp/fix-boot/mnt

# Step 4: Mount other necessary partitions
mkdir -p /tmp/fix-boot/mnt/boot
mount $EFI_PARTITION /tmp/fix-boot/mnt/boot

mkdir -p /tmp/fix-boot/mnt/home
mount -o subvol=home /dev/mapper/nixos-root /tmp/fix-boot/mnt/home

mkdir -p /tmp/fix-boot/mnt/nix
mount -o subvol=nix /dev/mapper/nixos-root /tmp/fix-boot/mnt/nix

# Step 5: Prepare for chroot
# For NixOS live USB
sudo nixos-enter --root /mnt

# For other linux live USBs
# mount --bind /proc /tmp/fix-boot/mnt/proc
# mount --bind /sys /tmp/fix-boot/mnt/sys
# mount --bind /dev /tmp/fix-boot/mnt/dev
# mount --bind /dev/pts /tmp/fix-boot/mnt/dev/pts
# mount --bind /run /tmp/fix-boot/mnt/run

# Step 6: fix boot configuration
# Reinstall systemd-boot
echo "Reinstalling systemd-boot..."
bootctl install

# Step 7: Clean up
echo "Cleaning up..."
umount -R /tmp/fix-boot/mnt
umount /tmp/btrfs_root
cryptsetup luksClose nixos-root
rm -rf /tmp/fix-boot /tmp/btrfs_root

echo "Boot repair completed successfully. You can now reboot."
echo "Run 'sudo reboot' to restart your system."
