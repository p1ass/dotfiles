#! /usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE="$(command -v claude || echo "$HOME/.local/bin/claude")"

if ! "$CLAUDE" plugin marketplace list 2>/dev/null | grep -q p1ass-dotfiles; then
  "$CLAUDE" plugin marketplace add "$DOTFILES_DIR/claude-plugins"
fi
"$CLAUDE" plugin install plamo-ja@p1ass-dotfiles
"$CLAUDE" plugin install herdr-bridge@p1ass-dotfiles
