# Awesome Sui Ecosystem Essentials

This guide distills high-value project knowledge from the Sui Foundation `awesome-sui` repository into practical selection guidance.

## 1. Official Foundations (Start Here)

- Official docs: `docs.sui.io`
- Core SDK/docs: `sdk.mystenlabs.com`
- Sui CLI / local workflow tools: `sui`, `suiup`
- Foundation-maintained curated index: `sui-foundation/awesome-sui`

Use these defaults first for stability and compatibility.

## 2. Developer Tooling Categories

### IDE and Coding Workflow
- Move support and syntax tooling: Move language support extensions and Move analyzer integrations
- AI coding support for Move/Sui workflows: specialized coding assistants listed in awesome-sui

When to use:
- New teams setting up editor/tooling standards
- Codebase-wide static checks and productivity improvements

### SDKs and Clients
- TypeScript SDK (`@mysten/sui`) for frontend/backend integrations
- Rust ecosystem support (official and community crates)

When to use:
- dApp backend services
- transaction builders, signers, wallet interactions, indexing clients

### dApp Scaffolding and Frontend Kits
- `sui-dapp-starter`
- Community starter templates and boilerplates listed in awesome-sui

When to use:
- Bootstrap app architecture quickly with wallet, network, and tx flows pre-wired

### Indexing, Data, and Analytics
- Official and community indexers from awesome-sui
- Graph-style query services and analytics platforms

When to use:
- historical queries
- portfolio views
- protocol analytics dashboards

### Infrastructure and Nodes
- RPC providers, fullnode deployments, and infra orchestration tools
- load-balanced or managed node options from ecosystem providers

When to use:
- production-grade RPC reliability
- lower latency and higher throughput needs

### Security and Auditing
- audit firms and security tools listed in awesome-sui
- CTF/security practice tracks (`MystenLabs/CTF`)

When to use:
- pre-mainnet audits
- vulnerability discovery and secure coding training

## 3. Sui-Native Product Categories (Awareness Map)

The awesome-sui list also tracks ecosystem applications across:
- wallets
- DeFi
- NFTs/gaming
- infra/data services
- developer platforms

Use this map to benchmark your project design and integration opportunities.

## 4. Tool Selection Heuristic

1. Prefer official/foundation-maintained tools for core dependencies.
2. Verify maintenance signal (recent commits, docs quality, active issues).
3. Confirm compatibility with your target network/version (`mainnet`, `testnet`, `devnet`).
4. Minimize critical-path dependencies; keep integration boundaries explicit.
5. Add community tools incrementally after baseline stability.

## 5. How This Skill Uses Awesome Sui Knowledge

- Project discovery and recommendation requests
- Stack design (SDK + indexer + RPC + wallet strategy)
- Security pipeline planning (CTF + auditing path)
- Build-vs-buy decisions for infra and data layers

Primary source:
- https://github.com/sui-foundation/awesome-sui
