#! /usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.."; pwd)"

# dotfile をホームディレクトリにリンク
for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".brewfile" ]] && continue
    [[ "$f" == ".idea" ]] && continue
    [[ "$f" == ".claude" ]] && continue
    [[ "$f" == ".zoekt.command" ]] && continue
    [[ "$f" == ".gitignore" ]] && continue
    [[ "$f" == ".config" ]] && continue

    echo "$f"
    unlink "$HOME/$f" 2>/dev/null || true
    ln -s "$DOTFILES_DIR/$f" "$HOME/$f"
done

# .config 配下は個別にリンク（ディレクトリごと上書きしない）
for d in "$DOTFILES_DIR"/.config/*/; do
    name=$(basename "$d")
    echo ".config/$name"
    mkdir -p "$HOME/.config"
    \rm -rf "$HOME/.config/$name"
    ln -s "$DOTFILES_DIR/.config/$name" "$HOME/.config/$name"
done

# .claude 配下をリンク
mkdir -p "$HOME/.claude"
echo ".claude/settings.json"
ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
echo ".claude/hooks"
\rm -rf "$HOME/.claude/hooks"
ln -sf "$DOTFILES_DIR/.claude/hooks" "$HOME/.claude/hooks"
