# Programmable Transaction Blocks (PTB) Guide

## Overview

Programmable Transaction Blocks (PTBs) are a powerful feature of Sui that allows you to compose multiple operations into a single atomic transaction. This enables complex workflows without deploying new smart contracts.

## Key Benefits

- **Atomicity**: All operations succeed or fail together
- **Gas Efficiency**: Single transaction fee for multiple operations
- **Composability**: Chain outputs from one command as inputs to another
- **No Contract Deployment**: Complex logic without publishing new packages

## PTB Structure

```
┌─────────────────────────────────────────────────────────────┐
│                 Programmable Transaction Block              │
├─────────────────────────────────────────────────────────────┤
│  Inputs:                                                    │
│    - Pure values (numbers, addresses, bytes)                │
│    - Object references (owned, shared, immutable)           │
│                                                             │
│  Commands:                                                  │
│    1. SplitCoins(coin, amounts) → [Coin, Coin, ...]        │
│    2. MergeCoins(target, sources)                          │
│    3. TransferObjects(objects, recipient)                   │
│    4. MoveCall(package, module, function, args)            │
│    5. MakeMoveVec(type, elements)                          │
│    6. Publish(modules, dependencies)                        │
│    7. Upgrade(package, ticket, modules, dependencies)       │
└─────────────────────────────────────────────────────────────┘
```

## TypeScript SDK Usage

### Basic Setup

```typescript
import { Transaction } from '@mysten/sui/transactions';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';

const client = new SuiClient({ url: getFullnodeUrl('testnet') });
const tx = new Transaction();
```

### Split and Transfer Coins

```typescript
// Split gas coin into multiple coins
const [coin1, coin2, coin3] = tx.splitCoins(tx.gas, [
    tx.pure('u64', 1000),
    tx.pure('u64', 2000),
    tx.pure('u64', 3000),
]);

// Transfer to different recipients
tx.transferObjects([coin1], tx.pure('address', '0xRecipient1'));
tx.transferObjects([coin2], tx.pure('address', '0xRecipient2'));
tx.transferObjects([coin3], tx.pure('address', '0xRecipient3'));
```

### Merge Coins

```typescript
// Merge multiple coins into one
tx.mergeCoins(
    tx.object('0xTargetCoinId'),
    [
        tx.object('0xCoin1'),
        tx.object('0xCoin2'),
    ]
);
```

### Call Move Functions

```typescript
// Call a Move function
tx.moveCall({
    target: '0xPackageId::module_name::function_name',
    arguments: [
        tx.object('0xObjectId'),
        tx.pure('u64', 100),
        tx.pure('address', '0xRecipient'),
    ],
    typeArguments: ['0x2::sui::SUI'],
});
```

### Complex Multi-Step Transaction

```typescript
const tx = new Transaction();

// Step 1: Split coins for payment
const [paymentCoin] = tx.splitCoins(tx.gas, [tx.pure('u64', 10000)]);

// Step 2: Call purchase function
const [item] = tx.moveCall({
    target: '0xShop::shop::purchase',
    arguments: [
        tx.object('0xShopId'),
        paymentCoin,
    ],
});

// Step 3: Transfer item to buyer
tx.transferObjects([item], tx.pure('address', buyerAddress));

// Execute
const result = await client.signAndExecuteTransaction({
    signer: keypair,
    transaction: tx,
});
```

### Using Transaction Results

```typescript
// Results from one command can be used in subsequent commands
const [splitCoin] = tx.splitCoins(tx.gas, [tx.pure('u64', 1000)]);

// Use the split coin in a Move call
tx.moveCall({
    target: '0xPackage::module::deposit',
    arguments: [
        tx.object('0xVaultId'),
        splitCoin,  // Result from previous command
    ],
});
```

## CLI Usage

### Basic Commands

```bash
# Split coins
sui client ptb \
    --split-coins gas [1000, 2000, 3000] \
    --assign coins \
    --transfer-objects [coins.0] @0xRecipient1 \
    --transfer-objects [coins.1] @0xRecipient2

# Merge coins
sui client ptb \
    --merge-coins @0xTargetCoin [@0xCoin1, @0xCoin2]

# Transfer objects
sui client ptb \
    --transfer-objects [@0xObject1, @0xObject2] @0xRecipient
```

### Move Call via CLI

```bash
sui client ptb \
    --move-call 0xPackage::module::function \
        @0xObjectArg \
        100u64 \
        @0xAddressArg \
    --gas-budget 10000000
```

### Complex PTB via CLI

```bash
sui client ptb \
    --split-coins gas [10000] \
    --assign payment \
    --move-call 0xShop::shop::purchase @0xShopId payment.0 \
    --assign item \
    --transfer-objects [item.0] @0xBuyer \
    --gas-budget 10000000
```

## Common Patterns

### 1. Batch Transfers

```typescript
interface Transfer {
    recipient: string;
    amount: number;
}

function batchTransfer(transfers: Transfer[]) {
    const tx = new Transaction();
    
    const coins = tx.splitCoins(
        tx.gas,
        transfers.map(t => tx.pure('u64', t.amount))
    );
    
    transfers.forEach((transfer, i) => {
        tx.transferObjects([coins[i]], tx.pure('address', transfer.recipient));
    });
    
    return tx;
}
```

### 2. Swap Pattern

```typescript
function swap(coinAId: string, minAmountOut: number) {
    const tx = new Transaction();
    
    // Get coin to swap
    const coinA = tx.object(coinAId);
    
    // Call swap function
    const [coinB] = tx.moveCall({
        target: '0xDex::swap::swap_a_to_b',
        arguments: [
            tx.object('0xPoolId'),
            coinA,
            tx.pure('u64', minAmountOut),
        ],
    });
    
    // Transfer result to sender
    tx.transferObjects([coinB], tx.pure('address', senderAddress));
    
    return tx;
}
```

### 3. Create and Configure Object

```typescript
function createAndConfigure() {
    const tx = new Transaction();
    
    // Create object
    const [obj] = tx.moveCall({
        target: '0xPackage::module::create',
        arguments: [],
    });
    
    // Configure object
    tx.moveCall({
        target: '0xPackage::module::set_name',
        arguments: [obj, tx.pure('string', 'MyObject')],
    });
    
    tx.moveCall({
        target: '0xPackage::module::set_value',
        arguments: [obj, tx.pure('u64', 100)],
    });
    
    // Transfer to owner
    tx.transferObjects([obj], tx.pure('address', ownerAddress));
    
    return tx;
}
```

## Gas Management

### Setting Gas Budget

```typescript
tx.setGasBudget(10000000); // 0.01 SUI
```

### Using Specific Gas Coin

```typescript
tx.setGasPayment([{ objectId: '0xGasCoinId', version: '1', digest: '...' }]);
```

### Sponsor Transactions

```typescript
// Sponsor pays for gas
tx.setSender(userAddress);
tx.setGasOwner(sponsorAddress);
```

## Error Handling

```typescript
try {
    const result = await client.signAndExecuteTransaction({
        signer: keypair,
        transaction: tx,
        options: {
            showEffects: true,
            showEvents: true,
        },
    });
    
    if (result.effects?.status.status === 'failure') {
        console.error('Transaction failed:', result.effects.status.error);
    }
} catch (error) {
    console.error('Transaction error:', error);
}
```

## Best Practices

1. **Estimate Gas First**: Use `dryRunTransaction` to estimate gas
2. **Handle Failures**: Always check transaction status
3. **Batch When Possible**: Combine related operations
4. **Use Type Arguments**: Specify generic types explicitly
5. **Validate Inputs**: Check object existence before building PTB
