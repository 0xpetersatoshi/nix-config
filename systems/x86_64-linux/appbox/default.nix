{
  pkgs,
  config,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  # Enable stylix theme
  ${namespace}.theme.stylix = {
    enable = true;
    theme = "tokyo-night-storm";
  };

  # Add dockerhost group to match TrueNAS permissions
  users = {
    users.${config.user.name} = {
      extraGroups = ["apps"];
    };

    groups.apps = {
      gid = 568; # Match the GID from TrueNAS
    };
  };

  fileSystems."/mnt/appdata" = {
    device = "10.19.50.2:/mnt/flashpool/appdata";
    fsType = "nfs";
    options = ["nfsvers=4" "hard" "rsize=131072" "wsize=131072"];
  };

  fileSystems."/mnt/media" = {
    device = "10.19.50.2:/mnt/flashpool/data";
    fsType = "nfs";
    options = ["nfsvers=4" "hard" "rsize=1048576" "wsize=1048576"];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    drivers = {
      enable = true;
      hasIntelCpu = true;
    };

    enableAllFirmware = true;
  };

  networking.hostName = "appbox";
  roles.server.enable = true;

  # Generate SSH key for the user if it doesn't exist
  system.activationScripts.generateUserSSHKey = ''
    if [ ! -f /home/${config.user.name}/.ssh/id_ed25519 ]; then
      mkdir -p /home/${config.user.name}/.ssh
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /home/${config.user.name}/.ssh/id_ed25519 -N ""
      chown -R ${config.user.name}:users /home/${config.user.name}/.ssh
      chmod 700 /home/${config.user.name}/.ssh
      chmod 600 /home/${config.user.name}/.ssh/id_ed25519
      chmod 644 /home/${config.user.name}/.ssh/id_ed25519.pub
    fi
  '';

  services = {
    virtualisation = {
      docker.enable = true;
      podman.enable = false;
    };
  };

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = false;
    };

    stateVersion = "25.05";
  };
}
