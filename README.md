# Sui Move Development Skill

A comprehensive skill for Sui blockchain Move smart contract development. This skill provides guidance, code templates, reference documentation, and best practices for building on Sui.

## Features

- **Move Language Fundamentals** - Types, abilities, borrowing, generics
- **Sui Object Model** - Objects, ownership, transfers, dynamic fields
- **Programmable Transaction Blocks (PTB)** - Multi-command transactions
- **Testing Patterns** - Unit tests, scenario tests, expected failures
- **Deployment Automation** - Build, test, and publish scripts
- **Upgrade Strategies** - Version management and migration patterns
- **Toolchain Management** - Install and switch Sui CLI versions with `suiup`
- **Full-Stack Starter** - Bootstrap Sui dApps with `sui-dapp-starter`
- **Move Language Canon** - Consolidated key rules from Move Book

## Directory Structure

```
sui-dev-skill/
├── SKILL.md                    # Main skill definition
├── README.md                   # This file
├── references/                 # Reference documentation
│   ├── core_topics.md          # Core concepts guide
│   ├── move-book-essentials.md # Key Move Book semantics
│   ├── object_model.md         # Object model deep dive
│   ├── ptb_guide.md            # PTB usage guide
│   ├── sui-dapp-starter.md     # Full-stack starter guide
│   └── suiup.md                # suiup install/version guide
└── scripts/                    # Code examples and utilities
    ├── setup_env.sh            # Environment setup
    ├── setup_suiup.sh          # Preferred setup via suiup
    ├── init_sui_dapp_starter.sh # Starter template bootstrap
    ├── deploy.sh               # Deployment automation
    ├── example_module.move     # Basic module template
    ├── ownership_examples.move # Ownership patterns
    ├── advanced_examples.move  # Dynamic fields, events, OTW
    ├── test_examples.move      # Testing patterns
    ├── version_check.sh        # Version checking
    └── version_conflict_check.sh
```

## Quick Start

### 1. Environment Setup

```bash
# Recommended: bootstrap Sui CLI via suiup
./scripts/setup_suiup.sh sui@testnet

# Manual install using suiup install script
curl -sSfL https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh | sh
suiup install sui@testnet -y
suiup show
suiup which

# Fallback: direct cargo install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install --git https://github.com/MystenLabs/sui.git --branch main sui-cli
```

### 2. Create a New Project

```bash
# Option A: New Move package
sui move new my_project
cd my_project

# Option B: Full-stack starter template (interactive)
./scripts/init_sui_dapp_starter.sh

# Or directly:
pnpm create sui-dapp@latest
```

### 3. Build and Test

```bash
sui move build
sui move test
```

### 4. Deploy

```bash
sui client publish --gas-budget 100000000
```

## Core Concepts

### Object Definition

```move
public struct MyObject has key, store {
    id: UID,
    value: u64,
}
```

### Ownership Types

| Type | Creation | Access |
|------|----------|--------|
| Address-owned | `transfer::transfer` | Owner only |
| Shared | `transfer::share_object` | Anyone |
| Immutable | `transfer::freeze_object` | Anyone (read-only) |

### Abilities

| Ability | Meaning |
|---------|---------|
| `copy` | Can be copied |
| `drop` | Can be dropped |
| `store` | Can be stored in objects |
| `key` | Can be an object |

## Code Examples

### Basic Module

```move
module package::example {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    public struct Item has key, store {
        id: UID,
        value: u64,
    }

    public fun create(value: u64, ctx: &mut TxContext) {
        let item = Item {
            id: object::new(ctx),
            value,
        };
        transfer::transfer(item, tx_context::sender(ctx));
    }
}
```

### PTB with TypeScript

```typescript
import { Transaction } from '@mysten/sui/transactions';

const tx = new Transaction();
const [coin] = tx.splitCoins(tx.gas, [tx.pure('u64', 1000)]);
tx.transferObjects([coin], tx.pure('address', recipient));

await client.signAndExecuteTransaction({ signer: keypair, transaction: tx });
```

## Reference Documentation

- [`references/core_topics.md`](references/core_topics.md) - Complete guide to Move and Sui concepts
- [`references/move-book-essentials.md`](references/move-book-essentials.md) - Essential Move Book rules and patterns
- [`references/object_model.md`](references/object_model.md) - Deep dive into Sui's object model
- [`references/ptb_guide.md`](references/ptb_guide.md) - Programmable Transaction Blocks guide
- [`references/sui-dapp-starter.md`](references/sui-dapp-starter.md) - Full-stack starter setup and workflows
- [`references/suiup.md`](references/suiup.md) - `suiup` install and version management

## External Resources

- [Move Book](https://move-book.com) - Official Move language tutorial
- [Move Book Reference](https://move-book.com/reference/) - Detailed language semantics
- [Sui Documentation](https://docs.sui.io) - Sui platform documentation
- [Sui GitHub](https://github.com/MystenLabs/sui) - Source code and examples
- [Sui TypeScript SDK](https://sdk.mystenlabs.com/typescript) - TypeScript SDK documentation
- [sui-dapp-starter](https://github.com/suiware/sui-dapp-starter) - Sui full-stack starter templates
- [suiup](https://github.com/MystenLabs/suiup) - Sui ecosystem CLI version manager

## Version

- Skill Version: 2.0.0
- Compatible with: Sui latest stable release

## Contributing

Contributions are welcome! Please follow Sui Move best practices and keep documentation clear and concise.
