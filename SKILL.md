---
name: sui-move
description: Sui Move smart contract development skill covering object model, ownership system, PTB transactions, dynamic fields, toolchain setup with suiup, full-stack dApp bootstrapping with sui-dapp-starter, and core concepts. Provides comprehensive guidance for Sui blockchain Move development, testing, deployment, and upgrades.
version: 2.0.0
---

# Sui Move Development Skill

This skill provides comprehensive guidance, reusable code snippets, reference documentation, and templates for Sui blockchain Move smart contract development.

## Core Capabilities

### 1. Move Language Fundamentals
- Type system and primitive types (u8, u64, u128, bool, address, vector)
- Struct definitions and abilities system (copy, drop, store, key)
- Function definitions, visibility, and generics
- Borrowing and references (&T, &mut T)
- Copy/Move semantics

### 2. Sui Object Model
- Object definition (structs with `key` ability, first field must be `id: UID`)
- Ownership types: Address-owned, Shared, Immutable, Object-owned
- Object lifecycle management
- UID and TxContext usage

### 3. Storage Functions
- `transfer::transfer` / `transfer::public_transfer` - Object transfer
- `transfer::share_object` / `transfer::public_share_object` - Shared objects
- `transfer::freeze_object` - Freeze as immutable
- `transfer::public_receive` - Receive objects

### 4. Dynamic Fields
- `sui::dynamic_field` module usage
- Dynamic add/remove/borrow operations
- Dynamic Object Fields

### 5. Programmable Transaction Blocks (PTB)
- PTB concepts and advantages
- Building PTBs with TypeScript SDK
- CLI commands: split-coins, merge-coins, transfer-objects
- Multi-command composition

### 6. Module and Package Management
- Move.toml configuration
- Module initialization (init function)
- One Time Witness (OTW) pattern
- Publisher object acquisition

### 7. Testing and Deployment
- Unit test writing (#[test])
- Test attributes (#[expected_failure])
- sui move build / test / publish
- Gas budget management

### 8. Contract Upgrades
- Upgrade strategies and migration
- Version compatibility checking
- BCS serialization

### 9. Toolchain Management with suiup
- Install and manage Sui ecosystem CLIs with `suiup`
- Pin network-aligned versions (e.g., `sui@testnet`, `sui@devnet`)
- Switch defaults with `suiup default set`
- Diagnose PATH/version issues with `suiup which` and `suiup doctor`

### 10. Full-Stack dApp Bootstrapping
- Scaffold production-ready Sui full-stack apps with `sui-dapp-starter`
- Use CLI bootstrap (`pnpm create sui-dapp@latest`) or GitHub template mode
- Initialize starter templates: Greeting (React), Greeting (Next.js), Counter (React)
- Follow localnet workflow (`localnet:start`, `localnet:deploy`, `localnet:faucet`, `start`)

---

## Usage Guide

When asked about Sui Move development tasks, this skill provides:

1. **Code Templates** - Standard module structure, object definitions, transfer patterns
2. **Shell Scripts** - Environment installation, build and deployment automation
3. **Reference Documentation** - Move language features, Sui-specific concepts
4. **Best Practices** - Security patterns, error handling, upgrade strategies

For toolchain install/version selection tasks, read `references/suiup.md` first, then apply `scripts/setup_suiup.sh` for a reproducible setup flow.
For full-stack project scaffolding tasks, read `references/sui-dapp-starter.md`, then use `scripts/init_sui_dapp_starter.sh` to bootstrap interactively.

---

## Quick Reference

### Object Definition Template
```move
module package::module_name {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// A struct with `key` ability is an object
    public struct MyObject has key {
        id: UID,
        value: u64,
    }

    /// Module initialization function
    fun init(ctx: &mut TxContext) {
        let obj = MyObject {
            id: object::new(ctx),
            value: 0,
        };
        transfer::transfer(obj, tx_context::sender(ctx));
    }
}
```

### Abilities Quick Reference
| Ability | Meaning | Use Case |
|---------|---------|----------|
| `copy` | Value can be copied | Primitive types, config data |
| `drop` | Value can be implicitly dropped | Temporary data, no explicit destruction needed |
| `store` | Value can be stored in global storage | Can be embedded in other objects, public transfer |
| `key` | Value can be used as object | Top-level objects, requires UID |

### Ownership Types Quick Reference
| Type | Creation Method | Access |
|------|-----------------|--------|
| Address-owned | `transfer::transfer` | Owner only |
| Shared | `transfer::share_object` | Anyone (mutable/immutable) |
| Immutable | `transfer::freeze_object` | Anyone (read-only) |

---

## Directory Structure

```
sui-dev-skill/
├── SKILL.md                     # Main skill file
├── README.md                    # Project documentation
├── references/                  # Reference documentation
│   ├── core_topics.md           # Core concepts detailed guide
│   ├── object_model.md          # Object model deep dive
│   ├── ptb_guide.md             # PTB usage guide
│   ├── sui-dapp-starter.md      # Full-stack starter workflow and commands
│   └── suiup.md                 # Toolchain installation and version management
└── scripts/                     # Scripts and code examples
    ├── setup_env.sh             # Environment setup script
    ├── setup_suiup.sh           # Preferred toolchain bootstrap via suiup
    ├── init_sui_dapp_starter.sh # Bootstrap the sui-dapp-starter template
    ├── deploy.sh                # Deployment script
    ├── version_check.sh         # Bytecode diff checker
    ├── version_conflict_check.sh # Directory conflict checker
    ├── example_module.move      # Basic module template
    ├── ownership_examples.move  # Ownership patterns
    ├── advanced_examples.move   # Dynamic fields/events/generics
    └── test_examples.move       # Testing patterns
```

---

## External Resources

- [Move Book](https://move-book.com) - Official Move language tutorial
- [Sui Documentation](https://docs.sui.io) - Sui platform documentation
- [Sui GitHub](https://github.com/MystenLabs/sui) - Source code and examples
- [suiup](https://github.com/MystenLabs/suiup) - Installer and version manager for Sui ecosystem CLIs
- [sui-dapp-starter](https://github.com/suiware/sui-dapp-starter) - Full-stack Sui dApp starter template

---

## Version Information

- Skill Version: 2.0.0
- Compatible Sui Version: Latest stable
- Last Updated: 2024
