#!/usr/bin/env bash
#
# Standalone Theme Switcher for Dotfiles
# Runs Omarchy's authentic theme scripts (omarchy-theme-set, omarchy-theme-color, omarchy-theme-set-templates)
# Works on any Linux distribution without needing Omarchy installed at the system level.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export OMARCHY_PATH="$DOTFILES_DIR"
export PATH="$SCRIPT_DIR/omarchy-bin:$PATH"

# Run in headless mode by default if omarchy-shell GUI daemon is not installed on this distro
if ! command -v omarchy-shell &>/dev/null; then
  export OMARCHY_THEME_HEADLESS=1
fi

# Ensure default/themed points to templates
mkdir -p "$DOTFILES_DIR/default"
if [[ ! -e "$DOTFILES_DIR/default/themed" ]]; then
  ln -sfn ../themes/templates "$DOTFILES_DIR/default/themed"
fi

if [[ $# -eq 0 || "$1" == "-l" || "$1" == "--list" || "$1" == "list" ]]; then
  echo "Available themes:"
  for dir in "$SCRIPT_DIR"/*/; do
    name="$(basename "$dir")"
    if [[ -f "$dir/colors.toml" && "$name" != "templates" && "$name" != "current" && "$name" != "default" && "$name" != "omarchy-bin" && "$name" != "backgrounds" ]]; then
      echo "  • $name"
    fi
  done
  echo ""
  echo "Usage: ./switch-theme.sh <theme-name>"
  exit 0
fi

THEME_NAME="$1"

# Call the authentic Omarchy script
omarchy-theme-set "$THEME_NAME"

# Explicitly sync VS Code theme
omarchy-theme-set-vscode >/dev/null 2>&1 || true

# Also sync to dotfiles/themes/current for convenience
rm -rf "$SCRIPT_DIR/current"
mkdir -p "$SCRIPT_DIR/current"
if [[ -d "$HOME/.local/state/omarchy/current/theme" ]]; then
  cp -r "$HOME/.local/state/omarchy/current/theme"/* "$SCRIPT_DIR/current/"
fi

# Link background if available
BG_DIR="$SCRIPT_DIR/backgrounds/$THEME_NAME"
if [[ -d "$BG_DIR" ]]; then
  rm -rf "$SCRIPT_DIR/current/backgrounds"
  ln -sfn "$BG_DIR" "$SCRIPT_DIR/current/backgrounds"
fi

echo "✓ Applied theme '$THEME_NAME' using authentic Omarchy scripts."
echo "✓ Theme output active in: ~/.local/state/omarchy/current/theme/"
echo "✓ Synced into dotfiles:   $SCRIPT_DIR/current/"
