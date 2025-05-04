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
    initialPassword =
      mkOpt str "1"
      "The initial password to use";
    isNormalUser = mkBoolOpt true "Whether the user is a normal user";
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
        isNormalUser = cfg.isNormalUser;
        inherit (cfg) name initialPassword;
        home = "/home/${cfg.name}";
        group = "users";
        shell = pkgs.zsh;

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
