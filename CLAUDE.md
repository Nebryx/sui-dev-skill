# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Sui Move Development Skill** repository containing reusable code snippets, automation scripts, and reference documentation for building smart contracts on the Sui blockchain. The repository is itself a Claude Code skill (`sui-move`), designed to be loaded when working with Sui Move development tasks.

## Directory Structure

```
sui-dev-skill/
├── scripts/           # Shell scripts and Move code examples
├── references/        # Documentation on core Sui Move concepts
└── SKILL.md          # Skill metadata for Claude Code
```

## Development Commands

### Environment Setup
```bash
# Install Rust and Sui CLI
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install --git https://github.com/MystenLabs/sui.git --branch main sui-cli
```

### Build, Test, Deploy
```bash
sui move build                          # Compile Move modules
sui move test --path .                  # Run Move unit tests
sui client publish --gas-budget 10000   # Deploy to blockchain
```

### Automation Scripts
- `scripts/setup_env.sh` - Environment setup (Rust + Sui CLI)
- `scripts/deploy.sh [GAS_BUDGET]` - Automated deployment with error handling
- `scripts/version_check.sh` - Check for version differences during upgrades
- `scripts/version_conflict_check.sh` - Advanced version conflict detection

## Move Code Examples

The `scripts/` directory contains template Move modules demonstrating key patterns:

- `example_module.move` - Basic module with `key` struct and public function
- `advanced_examples.move` - Dynamic fields, vectors, and unit tests
- `ownership_examples.move` - Object ownership and transfer patterns
- `test_examples.move` - Unit testing patterns with `#[test]` attribute

## Module Structure Basics

Sui Move modules follow this pattern:
```move
module package_name::module_name {
    struct StructName has key {        // "key" = owned, can be stored
        id: u64,
        data: vector<u8>,
    }

    public fun create(...): StructName { }  // Constructor
    // Additional public entry functions
}
```

Key capabilities: `key` (owned objects), `store` (can be wrapped), `copy` (copyable), `drop` (can be dropped).

## Contract Upgrade Workflow

1. Build with `sui move build`
2. Run `scripts/version_check.sh` to detect breaking changes
3. Deploy with `sui client publish`
4. Use `scripts/version_conflict_check.sh` for advanced conflict detection

See `references/core_topics.md` for detailed upgrade strategies including BCS serialization and access control.

## Skill Usage

When working on Sui Move tasks, invoke this skill via:
```
/skill sui-move
```

The skill provides:
- Environment setup and quickstart scripts
- Move module templates and code patterns
- Reference docs on objects, ownership, coin, collections, testing
- Upgrade and migration guidance
