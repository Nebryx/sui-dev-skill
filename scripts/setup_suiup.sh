#!/bin/bash

# Bootstrap Sui CLI through suiup.
# Usage: ./scripts/setup_suiup.sh [target]
# Example targets: sui@testnet, sui@devnet, sui@mainnet, sui@testnet-1.40.1

set -Eeuo pipefail

TARGET="${1:-sui@testnet}"

if ! command -v suiup >/dev/null 2>&1; then
  echo "Installing suiup..."
  curl -sSfL https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh | sh
fi

# install.sh commonly places binaries under ~/.local/bin
if ! command -v suiup >/dev/null 2>&1; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v suiup >/dev/null 2>&1; then
  echo "Error: suiup not found on PATH after install."
  echo 'Add to PATH: export PATH="$HOME/.local/bin:$PATH"'
  exit 1
fi

echo "Installing target: $TARGET"
suiup install "$TARGET" -y

echo "Current toolchain:"
suiup show
suiup which

if command -v sui >/dev/null 2>&1; then
  sui --version
fi

echo "Setup completed."
