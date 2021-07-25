#! /usr/bin/env bash
set -e
brew install federico-terzi/espanso/espanso
espanso --version
espanso register
espanso start
espanso install all-emoji
espanso restart
