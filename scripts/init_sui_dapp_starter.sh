#!/bin/bash

# Bootstrap a Sui full-stack starter project.
# Usage:
#   ./scripts/init_sui_dapp_starter.sh
#   ./scripts/init_sui_dapp_starter.sh --help
#   ./scripts/init_sui_dapp_starter.sh my-project

set -Eeuo pipefail

if ! command -v pnpm >/dev/null 2>&1; then
  echo "Error: pnpm is required. Install pnpm >= 9 first."
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Error: node is required. Install node >= 20 first."
  exit 1
fi

if ! command -v suibase >/dev/null 2>&1; then
  echo "Warning: suibase not found. Localnet commands may not work until suibase is installed."
fi

echo "Launching sui-dapp-starter scaffolder..."
pnpm create sui-dapp@latest "$@"

echo
echo "Next steps (inside your generated project):"
echo "  pnpm localnet:start"
echo "  pnpm localnet:deploy"
echo "  pnpm localnet:faucet"
echo "  pnpm start"
