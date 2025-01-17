#!/usr/bin/env zsh

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Print with color
print_status() {
  echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
  echo -e "${RED}[-]${NC} $1"
}

print_command() {
  echo -e "${YELLOW}[$]${NC} $1"
}

# Function to execute command with logging
execute() {
  print_command "$@"
  "$@"
}

# Check if stow is installed
if ! command -v stow >/dev/null 2>&1; then
  print_error "GNU Stow is not installed. Please install it first."
  exit 1
fi

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create necessary directories if they don't exist
print_status "Creating necessary directories..."
execute mkdir -p "${HOME}/.config"
execute mkdir -p "${HOME}/.local/bin"

# Function to safely stow files
safe_stow() {
  local dir=$1
  local target=$2

  print_status "Stowing $dir to $target..."

  # First try to unstow in case there are existing links
  print_command "stow -D -d $DOTFILES_DIR/$dir -t $target ."
  stow -D -d "$DOTFILES_DIR/$dir" -t "$target" . 2>/dev/null || true

  # Then stow the files
  print_command "stow -v -d $DOTFILES_DIR/$dir -t $target ."
  if stow -v -d "$DOTFILES_DIR/$dir" -t "$target" .; then
    print_success "Successfully stowed $dir"
  else
    print_error "Failed to stow $dir"
    return 1
  fi
}

# Stow configuration files
print_status "Starting stow operations..."

# Stow .config files
safe_stow "config" "${HOME}"

# Stow local scripts
safe_stow "scripts" "${HOME}/.local"

# Stow home directory files
safe_stow "home" "${HOME}"

print_success "Installation complete!"
