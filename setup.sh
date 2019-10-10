#!/bin/bash

# dotfileをホームディレクトリにリンク
for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".brewfile" ]] && continue

    echo "$f"
    ln -s ${pwd}/$f $HOME/$f
done
