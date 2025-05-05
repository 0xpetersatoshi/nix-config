# Disko

Before installing nix, you need to use disko to configure the disk partitions:

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount systems/x86_64-linux/gpubox/disks.nix
```

If you see this error message:

```bash
mount: /mnt: unknown filesystem type 'ext4'.
       dmesg(1) may have more information after failed mount system call.

```

Check if the ext4 module is available:

```bash
lsmod | grep ext4
```

If there is no output, try loading the module:

```bash
modprobe ext4
```
