#!/bin/bash
# Environment Setup Scripts

# Install Rust and Sui CLI
set -Eeuo pipefail

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Ensure cargo/sui are on PATH for this shell session.
if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.cargo/env"
else
  export PATH="$HOME/.cargo/bin:$PATH"
fi

cargo install --git https://github.com/MystenLabs/sui.git --branch main sui-cli || {
  echo "Error: Failed to install Sui CLI"
  exit 1
}

sui move build || { echo "Error: Build failed"; exit 1; }

GAS_BUDGET=${1:-10000}
read -r -p "Publish with gas budget $GAS_BUDGET? (y/N): " CONFIRM
if [[ $CONFIRM =~ ^[yY]$ ]]; then
  sui client active-address >/dev/null 2>&1 || { echo "Error: sui client not initialized"; exit 1; }
  sui client publish --gas-budget "$GAS_BUDGET"
else
  echo "Publish canceled."
fi
