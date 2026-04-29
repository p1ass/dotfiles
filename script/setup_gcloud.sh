#! /usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$HOME/google-cloud-sdk"

if [[ -d "$INSTALL_DIR" ]]; then
  echo "Google Cloud SDK is already installed. Updating..."
  "$INSTALL_DIR/bin/gcloud" components update --quiet
else
  echo "Installing Google Cloud SDK..."
  curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"
fi
