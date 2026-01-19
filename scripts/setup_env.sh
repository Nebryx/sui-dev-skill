# Environment Setup Scripts

# Install Rust and Sui CLI

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install --git https://github.com/MystenLabs/sui.git --branch main sui-cli

# Quickstart: Compile and deploy a basic Sui Move project
sui move build
sui client publish --gas-budget 10000
