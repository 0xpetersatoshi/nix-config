{...}: {
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # Preserve existing Windows partitions by explicitly defining them
            # and setting their createMbr to false
            ESP = {
              size = "260M"; # Use exact size from your system
              type = "EFI";
              # This tells disko not to create or format this partition
              content.type = "filesystem";
              content.format = false;
              content.mountpoint = "/boot";
            };
            microsoftReserved = {
              size = "16M"; # Use exact size from your system
              type = "8300"; # Regular Linux partition type as placeholder
              content.type = "filesystem";
              content.format = false;
            };
            windowsC = {
              size = "316.9G"; # Use exact size from your system
              type = "8300"; # Regular Linux partition type as placeholder
              content.type = "filesystem";
              content.format = false;
            };
            windowsRecovery = {
              size = "2G"; # Use exact size from your system
              type = "8300"; # Regular Linux partition type as placeholder
              content.type = "filesystem";
              content.format = false;
            };
            # New NixOS partition using remaining space
            nixos = {
              size = "100%"; # Use remaining space
              content = {
                type = "luks";
                name = "nixos-enc";
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key"; # Temporary file for installation
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos"];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@swap" = {
                      mountpoint = "/.swapvol";
                      mountOptions = ["noatime"];
                      swap = {
                        swapfile.size = "4G"; # Adjust based on your needs
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
