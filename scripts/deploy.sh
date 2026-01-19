#!/bin/bash

# Automated deployment script for Sui Move contract

set -e

if ! command -v sui &> /dev/null
then
    echo "sui CLI could not be found, please install it first"
    exit 1
fi

echo "Building the Sui Move package..."
sui move build

echo "Publishing the package with gas budget 10000..."
sui client publish --gas-budget 10000

echo "Deployment completed successfully."
