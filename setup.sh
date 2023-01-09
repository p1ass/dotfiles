#! /usr/bin/env bash -ex 

./script/link_dotfile.sh
./script/setup_zsh.sh
./script/restore_brew.sh
./script/setup_asdf.sh
./script/install_espanso.sh
