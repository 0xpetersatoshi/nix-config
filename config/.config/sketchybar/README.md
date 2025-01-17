# Sketchybar

## Install

```bash
brew tap FelixKratz/formulae
brew install sketchybar
```

## Configuration

```bash
mkdir -p ~/dotfiles/.config/sketchybar
cp /opt/homebrew/opt/sketchybar/share/sketchybar/examples/sketchybarrc ~/dotfiles/.config/sketchybar/sketchybarrc
mkdir ~/dotfiles/.config/sketchybar/plugins
cp -r /opt/homebrew/opt/sketchybar/share/sketchybar/examples/plugins/ ~/dotfiles/.config/sketchybar/plugins/
chmod +x ~/dotfiles/.config/sketchybar/plugins/*
```

> **NOTE**: Ensure all scripts within the [plugins](./plugins/) and [items](./items/) directories are executable.

## Dependencies

- A nerd font:

  ```bash
  brew install --cask font-jetbrains-mono-nerd-font
  ```

- SF Symbols (MacOS symbols library):

  ```bash
  brew install --cask sf-symbols
  ```

- Sketchybar App font:

  ```bash
  curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.16/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
  ```

- Update to the latest icon mapping script from the [releases](https://github.com/kvndrsslr/sketchybar-app-font/releases)
  page.

  - At the end of the [icon_map_fn.sh](./plugins/icon_map_fn.sh) script, add the following:

    ```bash
    __icon_map "$1"

    echo "$icon_result"
    ```

## Resources

- [Sketchybar Setup](https://www.josean.com/posts/sketchybar-setup)
