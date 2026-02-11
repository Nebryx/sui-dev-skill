#!/bin/bash

# Clone and initialize the MystenLabs CTF repository.
# Usage:
#   ./scripts/setup_sui_ctf.sh
#   ./scripts/setup_sui_ctf.sh /path/to/target-dir

set -Eeuo pipefail

TARGET_DIR="${1:-CTF}"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required."
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "Error: pnpm is required."
  exit 1
fi

if [ -e "$TARGET_DIR" ]; then
  echo "Error: target path already exists: $TARGET_DIR"
  exit 1
fi

echo "Cloning MystenLabs/CTF into $TARGET_DIR ..."
git clone https://github.com/MystenLabs/CTF.git "$TARGET_DIR"

echo "Installing dependencies and initializing keypair ..."
cd "$TARGET_DIR/scripts"
pnpm install
pnpm run init-keypair

echo
echo "CTF setup complete. Next commands:"
echo "  cd $TARGET_DIR/scripts"
echo "  pnpm run moving-window"
echo "  pnpm run merchant"
echo "  pnpm run lootboxes"
echo "  pnpm run staking"
