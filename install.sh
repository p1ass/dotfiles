#!/bin/bash

set -euo pipefail

git clone https://github.com/p1ass/dotfiles.git ~/ghq/github.com/p1ass/dotfiles || true
cd ~/ghq/github.com/p1ass/dotfiles
./setup.sh
cd - > /dev/null
