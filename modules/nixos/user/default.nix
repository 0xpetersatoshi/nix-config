{
  config,
  lib,
  inputs,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.user;
in {
  options.user = with types; {
    name = mkOpt str "peter" "The name of the user's account";
    initialHashedPassword =
      mkOpt str "$6$8qMPXym8IqGqhbhS$oEjkslV1e0.9ZacVQIrF2StBBoeGNCIxuhHRTRqW.PLtBeXOy/wyxh.gbWcPj9DOvMHXiGrh.5xJTSgewQ7Bv0"
      "The initial password to use";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    extraOptions =
      mkOpt attrs {}
      "Extra options passed to users.users.<name>";
  };

  config = {
    nix = {
      nixPath = ["nixpkgs=${inputs.nixpkgs}"];

      # Enable automatic garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # Optimize store to remove unused dependencies
      settings.auto-optimise-store = true;
    };

    programs.zsh.enable = true;

    users.mutableUsers = false;
    users.users.${cfg.name} =
      {
        isNormalUser = true;
        inherit (cfg) name initialHashedPassword;
        home = "/home/${cfg.name}";
        group = "users";
        shell = pkgs.zsh;
        uid = 1000;

        # TODO: set in modules
        extraGroups =
          [
            "wheel"
            "audio"
            "sound"
            "video"
            "networkmanager"
            "input"
            "tty"
            "plugdev"
            "podman"
            "docker"
            "kvm"
            "libvirtd"
          ]
          ++ cfg.extraGroups;
      }
      // cfg.extraOptions;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm.bak";
    };
  };
}
