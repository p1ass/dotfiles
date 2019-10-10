#! /bin/bash

#VS Codeの拡張機能をインストール
# cat ./vscode-extensions.txt | while read line
# do
#     code --install-extension $line
# done

ln -s $(cd $(dirname $0); pwd)/settings.json $HOME/Library/ApplicationSupport/Code/User/settings.json
