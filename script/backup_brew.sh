#! /usr/bin/env bash

rm .brewfile
brew bundle dump --file=.brewfile
if [ -f .brewfile.lock.json ]; then
    rm .brewfile.lock.json
fi
