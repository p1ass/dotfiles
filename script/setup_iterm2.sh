#! /usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.."; pwd)"
ITERM2_DIR="$DOTFILES_DIR/iterm2"

if [[ ! -d "$ITERM2_DIR" ]]; then
  echo "iTerm2 config directory not found: $ITERM2_DIR"
  exit 1
fi

# iTerm2 に dotfiles の設定フォルダを参照させる
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_DIR"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

echo "iTerm2 configured to load preferences from: $ITERM2_DIR"
echo "Restart iTerm2 to apply."
