#! /usr/bin/env zsh

chsh -s `which zsh`
if [[ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# ファイルが存在したらエラーになるがスキップしたいのでオプションを指定
set -u
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
set -e
