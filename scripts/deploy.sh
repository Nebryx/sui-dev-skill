#!/bin/bash

# Automated deployment script for Sui Move contract

set -Eeuo pipefail

if ! command -v sui &> /dev/null
then
    echo "sui CLI could not be found, please install it first"
    exit 1
fi

echo "Building the Sui Move package..."
sui move build

if [ -z "$1" ]; then
  GAS_BUDGET=10000
else
  GAS_BUDGET=$1
fi

echo "Publishing the package with gas budget $GAS_BUDGET..."
sui client publish --gas-budget "$GAS_BUDGET" || {
  echo "Error: Deployment failed. Please check your Sui CLI and network connection."
  exit 1
}

echo "Deployment completed successfully."
