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
    [[ "$name" == "herdr" ]] && continue
    echo ".config/$name"
    mkdir -p "$HOME/.config"
    \rm -rf "$HOME/.config/$name"
    ln -s "$DOTFILES_DIR/.config/$name" "$HOME/.config/$name"
done

# herdr はソケットやセッション情報も同じディレクトリに置くため、設定ファイルだけリンクする
mkdir -p "$HOME/.config/herdr"
echo ".config/herdr/config.toml"
ln -sf "$DOTFILES_DIR/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# .claude 配下をリンク（既存ファイルを壊さないようファイル単位でリンク）
mkdir -p "$HOME/.claude"
if [[ ! -f "$HOME/.claude/settings.json" ]]; then
    echo ".claude/settings.json (copy)"
    cp "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
fi
mkdir -p "$HOME/.claude/hooks"
for f in "$DOTFILES_DIR"/.claude/hooks/*; do
    name=$(basename "$f")
    echo ".claude/hooks/$name"
    ln -sf "$f" "$HOME/.claude/hooks/$name"
done

echo ".claude/statusline-command.sh"
ln -sf "$DOTFILES_DIR/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
