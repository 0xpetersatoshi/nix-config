#!/bin/bash

# Use environment variable if set, otherwise use default
BACKUP_DIR="${BACKUP_DIR:-$HOME/dotfiles/packages}"
PACMAN_LIST="$BACKUP_DIR/pacman-packages.txt"
AUR_LIST="$BACKUP_DIR/aur-packages.txt"
FULL_LIST="$BACKUP_DIR/full-package-list.txt"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

backup_packages() {
    echo "📦 Backing up package lists..."

    # Export explicitly installed pacman packages
    echo "→ Backing up pacman packages..."
    pacman -Qqen > "$PACMAN_LIST"
    echo "✓ Saved to $PACMAN_LIST"

    # Export AUR packages
    echo "→ Backing up AUR packages..."
    pacman -Qqem > "$AUR_LIST"
    echo "✓ Saved to $AUR_LIST"

    # Export full package list with descriptions
    echo "→ Backing up full package list with descriptions..."
    pacman -Qe > "$FULL_LIST"
    echo "✓ Saved to $FULL_LIST"

    echo "✨ Backup complete!"
    echo "Found $(wc -l < "$PACMAN_LIST") pacman packages"
    echo "Found $(wc -l < "$AUR_LIST") AUR packages"
}

restore_packages() {
    if [[ ! -f "$PACMAN_LIST" || ! -f "$AUR_LIST" ]]; then
        echo "❌ Backup files not found!"
        exit 1
    fi

    echo "📦 Restoring packages..."

    # Install pacman packages
    echo "→ Installing pacman packages..."
    sudo pacman -S --needed - < "$PACMAN_LIST"

    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        echo "⚠️  yay is not installed. Installing yay first..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd ..
        rm -rf yay
    fi

    # Install AUR packages
    echo "→ Installing AUR packages..."
    yay -S --needed - < "$AUR_LIST"

    echo "✨ Restore complete!"
}

# Show usage if no arguments provided
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [backup|restore]"
    exit 1
fi

# Handle command line arguments
case "$1" in
    "backup")
        backup_packages
        ;;
    "restore")
        restore_packages
        ;;
    *)
        echo "Invalid option. Use 'backup' or 'restore'"
        exit 1
        ;;
esac
