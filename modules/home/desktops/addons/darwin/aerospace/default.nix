{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.addons.darwin.aerospace;
  inherit (config.lib.stylix) colors;
in {
  options.desktops.addons.darwin.aerospace = {
    enable = mkEnableOption "Enable aerospace configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."aerospace/aerospace.toml".text = ''
      # You can use it to add commands that run after login to macOS user session.
      # 'start-at-login' needs to be 'true' for 'after-login-command' to work
      # Available commands: https://nikitabobko.github.io/AeroSpace/commands
      after-login-command = []

      # You can use it to add commands that run after AeroSpace startup.
      # 'after-startup-command' is run after 'after-login-command'
      # Available commands : https://nikitabobko.github.io/AeroSpace/commands
      after-startup-command = [
        'exec-and-forget ${pkgs.jankyborders}/bin/borders active_color=0xff${colors.base08} width=7.0',
      ]

      # Notify Sketchybar about workspace change
      exec-on-workspace-change = ['/usr/bin/env', 'bash', '-c',
        '${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(${pkgs.aerospace}/bin/aerospace list-workspaces --focused)',
      ]

      # Start AeroSpace at login
      start-at-login = true

      # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true

      # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
      # The 'accordion-padding' specifies the size of accordion padding
      # You can set 0 to disable the padding feature
      accordion-padding = 30

      # Possible values: tiles|accordion
      default-root-container-layout = 'tiles'

      # Possible values: horizontal|vertical|auto
      # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
      #               tall monitor (anything higher than wide) gets vertical orientation
      default-root-container-orientation = 'auto'

      # Possible values: (qwerty|dvorak)
      # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
      key-mapping.preset = 'qwerty'

      # Mouse follows focus when focused monitor changes
      # Drop it from your config, if you don't like this behavior
      # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
      # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
      on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

      # Gaps between windows (inner-*) and between monitor edges (outer-*).
      # Possible values:
      # - Constant:     gaps.outer.top = 8
      # - per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
      #                 in this example, 24 is a default value when there is no match.
      #                 monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
      #                 see: https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
      [gaps]
      inner.horizontal = 10
      inner.vertical =   10
      outer.left =       10
      outer.bottom =     10
      outer.top =        [{ monitor."^built-in retina display$" = 10 }, 45]
      outer.right =      10

      # 'main' binding mode declaration
      # see: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
      # 'main' binding mode must be always presented
      [mode.main.binding]

      # all possible keys:
      # - letters.        a, b, c, ..., z
      # - numbers.        0, 1, 2, ..., 9
      # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
      # - F-keys.         f1, f2, ..., f20
      # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
      #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
      # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
      #                   keypadMinus, keypadMultiply, keypadPlus
      # - Arrows.         left, down, up, right

      # All possible modifiers: cmd, alt, ctrl, shift

      # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

      # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
      # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
      # alt-enter = '''exec-and-forget osascript -e '
      # tell application "Terminal"
      #     do script
      #     activate
      # end tell'
      # '''

      # See: https://nikitabobko.github.io/AeroSpace/commands#layout
      cmd-alt-slash = 'layout tiles horizontal vertical'
      cmd-alt-comma = 'layout accordion horizontal vertical'

      # See: https://nikitabobko.github.io/AeroSpace/commands#focus
      cmd-h = 'focus left'
      cmd-j = 'focus down'
      cmd-k = 'focus up'
      cmd-l = 'focus right'

      # # See: https://nikitabobko.github.io/AeroSpace/commands#move
      alt-ctrl-h = 'move left'
      alt-ctrl-j = 'move down'
      alt-ctrl-k = 'move up'
      alt-ctrl-l = 'move right'

      # See: https://nikitabobko.github.io/AeroSpace/commands#resize
      cmd-alt-minus = 'resize smart -50'
      cmd-alt-equal = 'resize smart +50'

      # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
      cmd-1 = 'workspace 1'
      cmd-2 = 'workspace 2'
      cmd-3 = 'workspace 3'
      cmd-4 = 'workspace 4'
      cmd-5 = 'workspace 5'
      cmd-6 = 'workspace 6'
      cmd-7 = 'workspace 7'
      cmd-8 = 'workspace 8'
      cmd-9 = 'workspace 9'
      # alt-a = 'workspace A' # In your config, you can drop workspace bindings that you don't need
      # alt-b = 'workspace B'
      # alt-c = 'workspace C'
      # alt-d = 'workspace D'
      # alt-e = 'workspace E'
      # alt-f = 'workspace F'
      # alt-g = 'workspace G'
      # alt-i = 'workspace I'
      # alt-m = 'workspace M'
      # alt-n = 'workspace N'
      # alt-o = 'workspace O'
      # alt-p = 'workspace P'
      # alt-q = 'workspace Q'
      # alt-r = 'workspace R'
      # alt-s = 'workspace S'
      # alt-t = 'workspace T'
      # alt-u = 'workspace U'
      # alt-v = 'workspace V'
      # alt-w = 'workspace W'
      # alt-x = 'workspace X'
      # alt-y = 'workspace Y'
      # alt-z = 'workspace Z'

      # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
      cmd-shift-1 = 'move-node-to-workspace 1'
      cmd-shift-2 = 'move-node-to-workspace 2'
      cmd-shift-3 = 'move-node-to-workspace 3'
      cmd-shift-4 = 'move-node-to-workspace 4'
      cmd-shift-5 = 'move-node-to-workspace 5'
      cmd-shift-6 = 'move-node-to-workspace 6'
      cmd-shift-7 = 'move-node-to-workspace 7'
      cmd-shift-8 = 'move-node-to-workspace 8'
      cmd-shift-9 = 'move-node-to-workspace 9'
      # cmd-shift-a = 'move-node-to-workspace A'
      # cmd-shift-b = 'move-node-to-workspace B'
      # cmd-shift-c = 'move-node-to-workspace C'
      # cmd-shift-d = 'move-node-to-workspace D'
      # cmd-shift-e = 'move-node-to-workspace E'
      # cmd-shift-f = 'move-node-to-workspace F'
      # cmd-shift-g = 'move-node-to-workspace G'
      # cmd-shift-i = 'move-node-to-workspace I'
      # cmd-shift-m = 'move-node-to-workspace M'
      # cmd-shift-n = 'move-node-to-workspace N'
      # cmd-shift-o = 'move-node-to-workspace O'
      # cmd-shift-p = 'move-node-to-workspace P'
      # cmd-shift-q = 'move-node-to-workspace Q'
      # cmd-shift-r = 'move-node-to-workspace R'
      # cmd-shift-s = 'move-node-to-workspace S'
      # cmd-shift-t = 'move-node-to-workspace T'
      # cmd-shift-u = 'move-node-to-workspace U'
      # cmd-shift-v = 'move-node-to-workspace V'
      # cmd-shift-w = 'move-node-to-workspace W'
      # cmd-shift-x = 'move-node-to-workspace X'
      # cmd-shift-y = 'move-node-to-workspace Y'
      # cmd-shift-z = 'move-node-to-workspace Z'

      # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
      alt-tab = 'workspace-back-and-forth'
      # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
      alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

      # See: https://nikitabobko.github.io/AeroSpace/commands#mode
      alt-shift-semicolon = 'mode service'

      # 'service' binding mode declaration.
      # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
      [mode.service.binding]
      esc = ['reload-config', 'mode main']
      r = ['flatten-workspace-tree', 'mode main'] # reset layout
      #s = ['layout sticky tiling', 'mode main'] # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
      f = ['layout floating tiling', 'mode main'] # Toggle between floating and tiling layout
      backspace = ['close-all-windows-but-current', 'mode main']

      cmd-ctrl-h = ['join-with left', 'mode main']
      cmd-ctrl-j = ['join-with down', 'mode main']
      cmd-ctrl-k = ['join-with up', 'mode main']
      cmd-ctrl-l = ['join-with right', 'mode main']

      # Automatically open apps in their respective workspaces
      # Terminal
      [[on-window-detected]]
      if.app-id = "com.github.wez.wezterm"
      run = "move-node-to-workspace 1"

      [[on-window-detected]]
      if.app-id = "com.mitchellh.ghostty"
      run = "move-node-to-workspace 1"

      [[on-window-detected]]
      if.app-id = "net.kovidgoyal.kitty"
      run = "move-node-to-workspace 1"

      [[on-window-detected]]
      if.app-id = "com.apple.Terminal"
      run = "move-node-to-workspace 1"

      # Broswer
      [[on-window-detected]]
      if.app-id = "company.thebrowser.Browser"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "com.google.Chrome"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "com.brave.Browser"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "org.mozilla.firefox"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "com.apple.Safari"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "app.zen-browser.zen"
      run = "move-node-to-workspace 2"

      # Files
      [[on-window-detected]]
      if.app-id = "com.apple.Finder"
      run = "layout floating"

      # Chat
      [[on-window-detected]]
      if.app-id = "com.apple.MobileSMS"
      run = "move-node-to-workspace 3"

      [[on-window-detected]]
      if.app-id = "com.hnc.Discord"
      run = "move-node-to-workspace 3"

      [[on-window-detected]]
      if.app-id = "com.tinyspeck.slackmacgap"
      run = "move-node-to-workspace 3"

      [[on-window-detected]]
      if.app-id = "ru.keepcoder.Telegram"
      run = "move-node-to-workspace 3"

      # Music
      [[on-window-detected]]
      if.app-id = "com.apple.Music"
      run = "move-node-to-workspace 4"

      [[on-window-detected]]
      if.app-id = "com.spotify.client"
      run = "move-node-to-workspace 4"

      # Auth
      [[on-window-detected]]
      if.app-id = "com.1password.1password"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.yubico.authenticator"
      run = "layout floating"

      # Notes
      [[on-window-detected]]
      if.app-id = "com.apple.Notes"
      run = "move-node-to-workspace 5"

      [[on-window-detected]]
      if.app-id = "md.obsidian"
      run = "move-node-to-workspace 5"

      # Email
      [[on-window-detected]]
      if.app-id = "ch.protonmail.desktop"
      run = "move-node-to-workspace 6"

      [[on-window-detected]]
      if.app-id = "com.apple.mail"
      run = "move-node-to-workspace 6"

      # Date
      [[on-window-detected]]
      if.app-id = "com.apple.iCal"
      run = "layout floating"

      # SQL
      [[on-window-detected]]
      if.app-id = "com.tinyapp.TablePlus"
      run = "move-node-to-workspace 7"

      # Misc
      [[on-window-detected]]
      if.app-id = "com.linear"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.apple.systempreferences"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.raycast.macos"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "io.zsa.keymapp"
      run = "layout floating"
    '';
    home.packages = with pkgs; [
      aerospace
    ];
  };
}
