{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.samba;
  user = config.user;
  group = config.users.users.${config.user.name}.group;
in {
  options.services.${namespace}.samba = with types; {
    enable = mkEnableOption "Enable the (mount) samba drive";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        cifs-utils
      ];
    };

    fileSystems."/mnt/nugshare" = {
      device = "//10.19.50.2/nugshare";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        # HACK: gpg with yubikey <> sops-nix configuration not working as expected with nixos module
        # will need to manually create secret file for now until a fix is found
        "${automount_opts},credentials=${config.users.users.${user.name}.home}/.smbcredentials"
        "uid=${toString config.users.users.${user.name}.uid}"
        "gid=${toString config.users.groups.${group}.gid}"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    fileSystems."/mnt/media-archive" = {
      device = "//10.19.50.2/media-archive";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        # HACK: gpg with yubikey <> sops-nix configuration not working as expected with nixos module
        # will need to manually create secret file for now until a fix is found
        "${automount_opts},credentials=${config.users.users.${user.name}.home}/.smbcredentials"
        "uid=${toString config.users.users.${user.name}.uid}"
        "gid=${toString config.users.groups.${group}.gid}"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    fileSystems."/mnt/books" = {
      device = "//10.19.50.2/books";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        # HACK: gpg with yubikey <> sops-nix configuration not working as expected with nixos module
        # will need to manually create secret file for now until a fix is found
        "${automount_opts},credentials=${config.users.users.${user.name}.home}/.smbcredentials"
        "uid=${toString config.users.users.${user.name}.uid}"
        "gid=${toString config.users.groups.${group}.gid}"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };
  };
}
