{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.worktrunk;
  wtPkg = inputs.worktrunk.packages."${pkgs.system}".default;
in {
  options.cli.programs.worktrunk = with types; {
    enable = mkBoolOpt false "Whether or not to enable the worktrunk (wt) CLI";
  };

  config = mkIf cfg.enable {
    home.packages = [wtPkg];

    xdg.configFile."worktrunk/config.toml".source = ./config.toml;

    programs.zsh.initContent = mkIf config.programs.zsh.enable ''
      eval "$(command ${wtPkg}/bin/wt config shell init zsh)"
    '';

    programs.nushell.extraConfig = mkIf config.programs.nushell.enable (
      builtins.readFile (pkgs.runCommand "wt-nushell-init" {} ''
        ${wtPkg}/bin/wt config shell init nu > $out
      '')
    );
  };
}
