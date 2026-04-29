#! /usr/bin/env bash

set -euo pipefail

brew install asdf

# Node.js
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true
asdf install nodejs latest
asdf set --home nodejs latest

# Ruby
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git || true
asdf install ruby latest
asdf set --home ruby latest

# Python
asdf plugin add python || true
asdf install python latest
asdf set --home python latest

# Java
asdf plugin add java || true
asdf install java latest:corretto
asdf set --home java latest:corretto
