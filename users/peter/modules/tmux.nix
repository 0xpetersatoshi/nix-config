{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    keyMode = "vi";
    prefix = "C-a";
    mouse = true;
    # newSession = true;
    baseIndex = 1;
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      battery
      better-mouse-mode
      cpu
      fzf-tmux-url
      sensible
      vim-tmux-navigator
      yank

      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'macchiato' # or frappe, latte, mocha
          set -g @catppuccin_window_status_style "rounded"

          # Windows
          # set -g @catppuccin_window_text " #W "
          set -g @catppuccin_window_text " #{b:pane_current_path} :: #W "
          set -g @catppuccin_window_current_text " #{b:pane_current_path} :: #W "

          set -g status-right "#{E:@catppuccin_status_date_time}"
          set -agF status-right "#{E:@catppuccin_status_cpu}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -agF status-right "#{E:@catppuccin_status_battery}"
        '';
      }

      {
        plugin = mkTmuxPlugin {
          pluginName = "tmux-fzf";
          version = "unstable-2025-01-26";
          rtpFilePath = "main.tmux";
          src = pkgs.fetchFromGitHub {
            owner = "sainnhe";
            repo = "tmux-fzf";
            rev = "1547f18083ead1b235680aa5f98427ccaf5beb21";
            sha256 = "dMqvr97EgtAm47cfYXRvxABPkDbpS0qHgsNXRVfa0IM=";
          };
        };
      }
    ];

    extraConfig = ''
      # split pane horizontally
      unbind '"'
      bind | split-window -h

      # split pane vertically
      unbind %
      bind - split-window -v

      set -g status-position top  # Set status bar to top

      set-option -g default-command "reattach-to-user-namespace -l \$\{SHELL}"

      # Navigate panes with Vim keys with prefix
      setw -g mode-keys vi
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Use Alt-(HJKL) to resize panes
      bind -n M-h resize-pane -L 5
      bind -n M-j resize-pane -D 5
      bind -n M-k resize-pane -U 5
      bind -n M-l resize-pane -R 5

      # Make the status line pretty and add some modules
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
    '';
  };
}
