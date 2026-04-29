#! /usr/bin/env zsh

set -euo pipefail

chsh -s "$(which zsh)"

if [[ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
    # 既存の場合はサブモジュール（pure等）を確実に初期化・更新
    cd "${ZDOTDIR:-$HOME}/.zprezto"
    git pull
    git submodule update --init --recursive
    cd -
fi

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
