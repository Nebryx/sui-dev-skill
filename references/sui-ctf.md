# Sui Move CTF Essentials (MystenLabs)

This guide captures the most useful operational knowledge from the official MystenLabs CTF repository.

## 1. Scope and Learning Goals

The CTF repository focuses on practical Sui Move security challenges. Current challenge set:
- `moving-window`
- `merchant`
- `lootboxes`
- `staking`

Challenges are independent and can be solved in any order.

## 2. Repository Layout

- `contracts/`: vulnerable Move package and challenge modules
- `scripts/`: TypeScript scripts for setup, helper actions, and exploit solving

Important detail: challenge modules and the `flag` module are intentionally grouped in the same package so challenge solvers can be written as additional modules in that package.

## 3. Environment Setup

Recommended prerequisites:
- Node.js 18+
- `pnpm` package manager
- Sui CLI configured for testnet/devnet/localnet usage

Typical setup flow:
```bash
git clone https://github.com/MystenLabs/CTF.git
cd CTF/scripts
pnpm install
pnpm run init-keypair
```

Funding and explorer utilities are part of the workflow (faucet links and explorer links are provided by the project scripts/output).

## 4. Running Challenges

Run challenge-specific scripts from `CTF/scripts`:
```bash
pnpm run moving-window
pnpm run merchant
pnpm run lootboxes
pnpm run staking
```

Use these as both examples and test harnesses while iterating on exploit logic.

## 5. Challenge Themes to Practice

- Time-based logic and boundary handling (`moving-window`)
- Payment/token accounting and state validation (`merchant`)
- Randomness-related constraints and transaction restrictions (`lootboxes`)
- Stake lifecycle and lock semantics (`staking`)

## 6. Suggested Solver Workflow

1. Read the challenge module in `contracts/sources`.
2. Identify trust boundaries, permissions, and state invariants.
3. Draft exploit transactions in TypeScript scripts.
4. Execute against test environment and confirm flag path.
5. Document root cause and patch strategy.

## 7. Skill Integration Guidance

- Use this CTF workflow when users ask for security training, exploit analysis, or challenge walkthroughs.
- Pair with `references/sui-ts-sdk.md` for transaction composition and signing.
- Pair with `references/move-book-essentials.md` for language-level safety reasoning.
