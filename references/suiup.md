# suiup Reference

## Overview

`suiup` is the official installer and version manager for Sui ecosystem CLIs (`sui`, `mvr`, `walrus`, `move-analyzer`).
Use it when you need reproducible toolchain setup or fast version switching between networks.

## Install suiup

### Option 1 (recommended): install script
```bash
curl -sSfL https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh | sh
```

### Option 2: cargo
```bash
cargo install --git https://github.com/MystenLabs/suiup --locked
```

If `suiup` is not on PATH after installation:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Install and switch Sui CLI versions

```bash
# Check available versions
suiup list

# Install by channel
suiup install sui@testnet -y
suiup install sui@devnet -y
suiup install sui@mainnet -y

# Install an explicit version
suiup install sui@testnet-1.40.1 -y

# Check / set defaults
suiup default get
suiup default set sui@testnet

# Verify active binary
suiup show
suiup which
sui --version
```

## Other tools

```bash
suiup install mvr -y
suiup install walrus -y
suiup install move-analyzer@mainnet -y
```

## CI and Troubleshooting

```bash
# Diagnostic checks
suiup doctor
```

- For CI, set `GITHUB_TOKEN` to avoid rate limits on GitHub API calls.
- To customize install location, use `SUIUP_DEFAULT_BIN_DIR`.
- If PATH has multiple `sui` binaries, use `suiup which` to confirm the one in use.
