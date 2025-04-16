{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Corsair_MP600_MICRO_AA4GB506003BK9";
        content = {
          type = "gpt";
          partitions = {
            # Preserve existing Windows partitions by explicitly defining them
            # and setting their createMbr to false
            EFI = {
              size = "2G";
              type = "EF00";
              # This tells disko not to create or format this partition
              content.type = "filesystem";
              content.format = "vfat";
              content.mountpoint = "/boot";
            };

            microsoftReserved = {
              size = "16M";
              type = "8300"; # Regular Linux partition type as placeholder
              content.type = "filesystem";
              content.format = "ntfs";
            };

            windowsC = {
              size = "500G"; # Use exact size from your system
              type = "8300"; # Regular Linux partition type as placeholder
              content.type = "filesystem";
              content.format = "ntfs";
            };

            windowsRecovery = {
              size = "642M";
              type = "8300"; # Regular Linux partition type as placeholder
              content.type = "filesystem";
              content.format = "ntfs";
            };

            nixos = {
              start = "502G";
              end = "+1T";
              content = {
                type = "luks";
                name = "nixos-root";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  # disable to use interactive password entry
                  keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos" "-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      mountOptions = ["noatime"];
                      swap.swapfile.size = "1G";
                    };
                  };
                };
              };
            };

            archlinux = {
              start = "after:nixos";
              end = "100%";
              content = {
                type = "luks";
                name = "archlinux-root";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  # disable to use interactive password entry
                  keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "archlinux" "-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      mountOptions = ["noatime"];
                      swap.swapfile.size = "1G";
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
