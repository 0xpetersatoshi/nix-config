{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.languages.rust;
in {
  options.cli.languages.rust = with types; {
    enable = mkBoolOpt false "Whether or not to enable rust";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rustup
      # codelldb debugger
      vscode-extensions.vadimcn.vscode-lldb
    ];

    home.file.".cargo/config.toml".text = ''
      [net]
      git-fetch-with-cli = true
    '';

    home.sessionVariables = {
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME = "$HOME/.cargo";
    };
  };
}
