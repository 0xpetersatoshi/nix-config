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
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    extraOptions =
      mkOpt attrs {}
      "Extra options passed to users.users.<name>";
  };

  config = {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    programs.zsh.enable = true;

    users.mutableUsers = false;
    users.users.${cfg.name} =
      {
        isNormalUser = true;
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
