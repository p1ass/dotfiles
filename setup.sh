#!/bin/bash

# dotfileをホームディレクトリにリンク
for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".brewfile" ]] && continue

    echo "$f"
    unlink $HOME/$f
    ln -s $(cd $(dirname $0); pwd)/$f $HOME/$f
done
