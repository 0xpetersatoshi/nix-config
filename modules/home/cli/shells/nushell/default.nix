{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.shells.nushell;

  # TODO: Define this in a common module
  shellAliases = {
    cat = "bat";
    ll = "eza --icons=always -l";
    tree = "eza --icons=always --tree";
    v = "nvim";
    z = "zellij";
  };
in {
  options.cli.shells.nushell = with types; {
    enable = mkBoolOpt false "enable nushell";
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      inherit shellAliases;
    };
  };
}
