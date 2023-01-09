#! /usr/bin/env bash

# dotfileをホームディレクトリにリンク
for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".brewfile" ]] && continue

    echo "$f"
    unlink $HOME/$f
    ln -s $(cd $(dirname $0); cd ../; pwd)/$f $HOME/$f
done
