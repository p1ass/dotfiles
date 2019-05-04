#!/bin/bash

# dotfileをホームディレクトリにリンク
for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".brewfile" ]] && continue

    echo "$f"
    ln -s $HOME/dotfiles/$f $HOME/$f
done

# brewをリストア
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
brew bundle install --file=.brewfile

#VS Codeの拡張機能をインストール
cat ./vscode-extensions.txt | while read line
do
code --install-extension $line
done
