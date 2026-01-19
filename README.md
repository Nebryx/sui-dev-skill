# Sui Move Development Skill

This skill provides comprehensive resources, scripts, and references for developers working on Sui Move smart contracts on the Sui blockchain.

## Features

- Environment setup and quickstart scripts for installing dependencies and preparing your development environment.
- Move module templates and code examples covering ownership, transfers, events, generics, and witness pattern.
- Utility scripts for automating contract deployment and detecting version conflicts during upgrades.
- Reference documentation covering core concepts such as objects, ownership, coin resources, collections, testing, and contract upgrade strategies.
- Visual assets including diagrams for ownership lifecycle, collections, and upgrade process.

## Directory Structure

- `scripts/` — shell scripts and Move code samples for development and testing.
- `references/` — markdown documentation explaining key Sui Move concepts and workflows.
- `assets/` — visual aids and diagrams supporting understanding of core concepts.
- `SKILL.md` — skill metadata and usage instructions for Claude.

## Usage

Use this skill when you are working on building, testing, or upgrading Sui Move smart contracts. It offers reusable code snippets, shell utilities, and reference docs that accelerate development and help ensure best practices.

## Getting Started

Run the `setup_env.sh` script in `scripts/` to install Rust, Sui CLI, and get a quickstart environment.

Example usage of Move module templates is included in the `example_module.move` and advanced examples in `advanced_examples.move`.

Automate your deployments with `deploy.sh` and use `version_check.sh` to help identify differences between module versions during upgrades.

## Contribution

Contributions and improvements are welcome. Please follow the Sui Move best practices and keep scripts and docs clear and concise.
