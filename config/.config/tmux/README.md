# Tmux

## Tmux Plugins

This config uses the [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) to manage plugins.

### Installing Plugins

1. Add a new plugin in [tmux.conf](./tmux.conf) with `set -g @plugin '<github-user>/<github-repo>'`
2. Press `prefix + I` to install the plugin

### Uninstalling Plugins

1. Comment out or remove the plugin in [tmux.conf](./tmux.conf)
2. Press `prefix + alt + u`
3. Remove the plugin from the [plugins](./plugins/) directory

### Update Plugins

1. Press `prefix + U`
