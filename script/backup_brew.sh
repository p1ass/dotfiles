#! /usr/bin/env bash

rm .brewfile
brew bundle dump --file=.brewfile
rm .brewfile.lock.json
