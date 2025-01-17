#!/bin/zsh

set -eux

echo "Updating Brewfile..."
brew bundle dump --file=$HOME/.config/brew/Brewfile --force

echo "Updated Brewfile!"

