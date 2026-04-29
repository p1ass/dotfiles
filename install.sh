#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$HOME/ghq/github.com/p1ass/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
  git -C "$DOTFILES_DIR" pull --rebase
else
  git clone https://github.com/p1ass/dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
./setup.sh
cd - > /dev/null
