# Sui TypeScript SDK Essentials

This reference summarizes the highest-value patterns from the official Sui TypeScript SDK docs.

## 1. Install and Package Layout

```bash
npm install @mysten/sui
```

The SDK is modular. Import only what you need:
- `@mysten/sui/client` for network clients
- `@mysten/sui/transactions` for PTB construction
- `@mysten/sui/keypairs/*` for keypair implementations
- `@mysten/sui/faucet` for test funding utilities

## 2. Network and Client Selection

Use explicit URLs for environment consistency:
- `https://fullnode.mainnet.sui.io:443`
- `https://fullnode.testnet.sui.io:443`
- `https://fullnode.devnet.sui.io:443`
- `http://127.0.0.1:9000` (localnet default)

Public RPC endpoints are rate-limited; for production backends use dedicated RPC.

Client guidance:
- Prefer `SuiGrpcClient` for new integrations.
- Use `SuiGraphQLClient` for query-heavy data access patterns.
- `SuiJsonRpcClient` remains for compatibility but is being phased out in favor of gRPC.
- Favor the shared Core API surface so transport can be swapped later.

## 3. Build, Sign, and Execute Transactions

```ts
import { SuiClient } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';

const client = new SuiClient({ url: 'https://fullnode.testnet.sui.io:443' });
const tx = new Transaction();

const [coin] = tx.splitCoins(tx.gas, [tx.pure('u64', 1_000_000)]);
tx.transferObjects([coin], tx.pure('address', '0x...recipient'));

const result = await client.signAndExecuteTransaction({
  signer: keypair,
  transaction: tx,
});
```

Post-execution checks:
- Validate `effects.status.status === 'success'`.
- Use `waitForTransaction`/equivalent confirmation flow before dependent reads.

## 4. Keypairs and Signatures

Supported key schemes include:
- Ed25519
- Secp256k1
- Secp256r1

Use deterministic test keys for CI and ephemeral keys for local experiments.

## 5. Faucet and Dev Flows

Use faucet utilities for Devnet/Testnet/localnet funding during development and tests.

```ts
import { requestSuiFromFaucetV1 } from '@mysten/sui/faucet';
```

## 6. Migration and Compatibility Notes

- The docs indicate v2+ ecosystem direction with dApp Kit support for app-facing signing UX.
- Keep integration boundaries clean: transaction construction in SDK layer, UI signing in wallet/dApp Kit layer.
- Track migration guides when upgrading SDK major versions.

## 7. Primary References

- https://sdk.mystenlabs.com/sui
- https://sdk.mystenlabs.com/sui/client
- https://sdk.mystenlabs.com/sui/transactions
- https://sdk.mystenlabs.com/sui/cryptography/keypairs
- https://sdk.mystenlabs.com/sui/faucet
- https://sdk.mystenlabs.com/sui/clients
