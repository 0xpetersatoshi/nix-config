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
  user = config.users.users.${config.user.name};
  group = config.users.groups.${user.group};

  shares = ["nugshare" "media-archive" "books"];

  # x-systemd.automount + the timeouts prevent hanging on a network split
  automountOpts = "x-systemd.automount,nofail,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
in {
  options.services.${namespace}.samba = with types; {
    enable = mkEnableOption "Enable the (mount) samba drive";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.security.${namespace}.sops.enable;
        message = "services.${namespace}.samba needs security.${namespace}.sops.enable for the share credentials.";
      }
    ];

    environment = {
      systemPackages = with pkgs; [
        cifs-utils
      ];
    };

    # Read by mount.cifs as root; contains the username=/password= lines.
    sops.secrets.smb-credentials.sopsFile = lib.snowfall.fs.get-file "secrets/samba.yaml";

    # Sidebar entries in Nautilus (and every other GTK file chooser). Clicking
    # one is a plain path access, which is what trips the autofs automount.
    snowfallorg.users.${config.user.name}.home.config.gtk.gtk3.bookmarks =
      map (share: "file:///mnt/${share}") shares;

    # Static hosts entry for the NAS. During a nixos switch that restarts
    # systemd-resolved, there's a brief window with no DNS resolver; if a CIFS
    # remount lands in that window it fails with "could not resolve address for
    # nas.home.internal" and takes home-manager activation down with it. A
    # /etc/hosts entry makes resolution independent of resolved being up.
    networking.hosts."10.10.20.2" = ["nas.home.internal"];

    fileSystems = listToAttrs (map (share:
      nameValuePair "/mnt/${share}" {
      device = "//nas.home.internal/${share}";
      fsType = "cifs";
      options = [
        "${automountOpts},credentials=${config.sops.secrets.smb-credentials.path}"
        "uid=${toString user.uid}"
        "gid=${toString group.gid}"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    })
    shares);
  };
}
