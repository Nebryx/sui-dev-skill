# sui-dapp-starter Reference

## Overview

`sui-dapp-starter` is a full-stack Sui starter toolkit with templates for:
- Greeting dApp (React)
- Greeting dApp (Next.js)
- Counter dApp (React)

Use this when users want a ready-to-run frontend + contract workflow instead of only a Move package.

## Prerequisites

```bash
# Required
node --version   # >= v20
pnpm --version   # >= v9

# Recommended for localnet workflows
suibase --version
```

## Bootstrap a project

### Option 1: Interactive CLI (recommended)
```bash
pnpm create sui-dapp@latest
```

### Option 2: GitHub template mode
```bash
# Greeting (React)
pnpm init:template:greeting-react

# Greeting (Next.js)
pnpm init:template:greeting-nextjs

# Counter (React)
pnpm init:template:counter-react
```

## Typical local development flow

Run these commands inside the generated project:

```bash
pnpm localnet:start
pnpm localnet:deploy
pnpm localnet:faucet
pnpm start
```

## Validation and tests

```bash
pnpm test
pnpm lint
pnpm typecheck
```

## Skill Usage Guidance

- If user asks for a production-like Sui dApp skeleton, prefer this starter.
- If user only needs a minimal on-chain module, prefer `sui move new`.
- Pair with this repository's toolchain flow in `references/suiup.md` when Sui CLI version management is needed.
