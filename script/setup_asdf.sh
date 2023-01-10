#! /usr/bin/env bash

brew install asdf

# Node.js
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs lts
asdf global nodejs lts

# Ruby
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest
asdf global ruby latest

# Python
asdf plugin-add python
asdf install python latest
asdf global python latest

# Perl
asdf plugin add perl
asdf install perl 5.36.0
asdf global perl 5.36.0

# Alias
asdf plugin add alias https://github.com/andrewthauer/asdf-alias.git
asdf alias java 17.0 corretto-17.0.3.6.1
