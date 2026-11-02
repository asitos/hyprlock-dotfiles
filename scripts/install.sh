#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Resolve directory locations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hyprlock"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
HYPRLOCK_LINK="$HYPR_DIR/hyprlock.conf"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}     hyprlock dotfiles installer      ${NC}"
echo -e "${BLUE}======================================${NC}"
info "Source repository : $REPO_DIR"
info "Target config dir : $TARGET_DIR"

# 1. Setup ~/.config/hyprlock
if [ "$REPO_DIR" != "$TARGET_DIR" ]; then
    info "Setting up files in $TARGET_DIR..."
    if [ -d "$TARGET_DIR" ] && [ ! -L "$TARGET_DIR" ]; then
        BACKUP_DIR="${TARGET_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
        warn "Existing $TARGET_DIR found. Backing up to $BACKUP_DIR"
        mv "$TARGET_DIR" "$BACKUP_DIR"
    fi
    mkdir -p "$TARGET_DIR"
    cp -r "$REPO_DIR"/* "$TARGET_DIR/"
    success "Copied dotfiles to $TARGET_DIR"
else
    success "Repository is located directly at $TARGET_DIR"
fi

# 2. Make all scripts executable
info "Ensuring script permissions..."
chmod +x "$TARGET_DIR"/scripts/*.sh
if [ -d "$TARGET_DIR/script" ]; then
    chmod +x "$TARGET_DIR"/script/*.sh 2>/dev/null || true
fi
success "Scripts marked as executable."

# 3. Link hyprlock.conf to ~/.config/hypr/hyprlock.conf
info "Configuring default hyprlock path ($HYPRLOCK_LINK)..."
mkdir -p "$HYPR_DIR"
if [ -f "$HYPRLOCK_LINK" ] || [ -L "$HYPRLOCK_LINK" ]; then
    CURRENT_TARGET="$(readlink -f "$HYPRLOCK_LINK" 2>/dev/null || true)"
    if [ "$CURRENT_TARGET" = "$TARGET_DIR/hyprlock.conf" ]; then
        success "$HYPRLOCK_LINK already points to $TARGET_DIR/hyprlock.conf"
    else
        BACKUP_CONF="${HYPRLOCK_LINK}.bak.$(date +%Y%m%d_%H%M%S)"
        warn "Backing up existing $HYPRLOCK_LINK -> $BACKUP_CONF"
        mv "$HYPRLOCK_LINK" "$BACKUP_CONF"
        ln -sf "$TARGET_DIR/hyprlock.conf" "$HYPRLOCK_LINK"
        success "Symlinked $HYPRLOCK_LINK -> $TARGET_DIR/hyprlock.conf"
    fi
else
    ln -sf "$TARGET_DIR/hyprlock.conf" "$HYPRLOCK_LINK"
    success "Symlinked $HYPRLOCK_LINK -> $TARGET_DIR/hyprlock.conf"
fi

# 4. Check for Terminess Nerd Font (Required)
info "Checking for Terminess Nerd Font..."
if fc-list : family | grep -iq "Terminess"; then
    success "Terminess Nerd Font is installed."
else
    warn "Terminess Nerd Font is NOT installed!"
    warn "This font is strictly required for TUI ASCII boxes, clock, and media icons."

    FONT_INSTALLED=0

    # If Arch Linux pacman is available
    if command -v pacman >/dev/null 2>&1; then
        echo -n "Arch Linux detected. Install ttf-terminus-nerd via pacman now? [y/N]: "
        read -r reply </dev/tty 2>/dev/null || reply="n"
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            if sudo pacman -S --needed ttf-terminus-nerd; then
                FONT_INSTALLED=1
                success "ttf-terminus-nerd installed successfully."
            fi
        fi
    fi

    # Fallback: offer manual font directory download
    if [ "$FONT_INSTALLED" -eq 0 ] && command -v curl >/dev/null 2>&1; then
        echo -n "Download Terminess Nerd Font to ~/.local/share/fonts/ now? [Y/n]: "
        read -r reply </dev/tty 2>/dev/null || reply="y"
        if [[ ! "$reply" =~ ^[Nn]$ ]]; then
            FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/TerminessNerdFont"
            mkdir -p "$FONT_DIR"
            TMP_ZIP="/tmp/Terminus.tar.xz"
            info "Downloading Terminus Nerd Font from GitHub..."
            if curl -fL --connect-timeout 15 -o "$TMP_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.tar.xz"; then
                tar -xf "$TMP_ZIP" -C "$FONT_DIR"
                rm -f "$TMP_ZIP"
                fc-cache -f "$FONT_DIR"
                success "Terminess Nerd Font installed to $FONT_DIR"
                FONT_INSTALLED=1
            else
                warn "Could not download automatically (network or GitHub unreachable)."
            fi
        fi
    fi

    if [ "$FONT_INSTALLED" -eq 0 ]; then
        warn "Please install Terminess Nerd Font manually:"
        echo "  • Arch Linux:   sudo pacman -S ttf-terminus-nerd"
        echo "  • Fedora:       sudo dnf install terminus-fonts-nerd-fonts"
        echo "  • Debian/Ubuntu: Download from https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.tar.xz"
        echo "                   Extract to ~/.local/share/fonts/ and run 'fc-cache -fv'"
    fi
fi

# 5. Dependency checks
info "Checking required tools..."
if command -v hyprlock >/dev/null 2>&1; then
    success "hyprlock is installed."
else
    warn "hyprlock command not found. Please install hyprlock."
fi

if command -v playerctl >/dev/null 2>&1; then
    success "playerctl is installed."
else
    warn "playerctl is missing. Media player widget requires playerctl."
    echo "  Install via: sudo pacman -S playerctl  OR  sudo apt install playerctl"
fi

echo ""
success "All done! hyprlock config installed successfully."
info "Test your lock screen with: hyprlock"
info "Add to ~/.config/hypr/hyprland.conf for keybinding:"
echo "    bind = \$mainMod, L, exec, hyprlock"
