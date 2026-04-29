#! /usr/bin/env bash -ex

# 最初に sudo 認証を行い、バックグラウンドでタイムスタンプを維持する
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

./script/link_dotfile.sh
./script/setup_zsh.sh
./script/restore_brew.sh

# restore_brew.sh はサブプロセスなので、ここで改めて PATH を通す
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

./script/setup_asdf.sh
./script/setup_macos.sh

# Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash
