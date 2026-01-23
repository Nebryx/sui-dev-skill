# Sui Move Core Concepts Reference

## 1. Environment Setup

### 1.1 Requirements
- **Operating System**: Linux, macOS, Windows (WSL2 recommended)
- **Dependencies**: Rust, Cargo, Sui CLI
- **Official Guide**: [Sui Installation Docs](https://docs.sui.io/build/install)

### 1.2 Quick Installation
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Sui CLI
cargo install --git https://github.com/MystenLabs/sui.git --branch main sui-cli

# Verify installation
sui --version
```

---

## 2. Move Language Fundamentals

### 2.1 Primitive Types
| Type | Description | Example |
|------|-------------|---------|
| `u8`, `u16`, `u32`, `u64`, `u128`, `u256` | Unsigned integers | `let x: u64 = 100;` |
| `bool` | Boolean | `let b: bool = true;` |
| `address` | Address | `let addr: address = @0x1;` |
| `vector<T>` | Dynamic array | `let v: vector<u8> = b"hello";` |

### 2.2 Abilities System

Move's abilities system controls type behavior:

```move
public struct Foo has copy, drop, store { x: u64 }
public struct Coin has store { value: u64 }
```

| Ability | Meaning | Auto-granted When |
|---------|---------|-------------------|
| `copy` | Value can be copied | All fields have copy |
| `drop` | Value can be implicitly dropped | All fields have drop |
| `store` | Value can be stored in global storage | All fields have store |
| `key` | Value can be used as global storage key | Must be explicitly declared |

### 2.3 Copy vs Move Semantics

```move
let foo = Foo { x: 0 };      // Foo has copy
let foo2 = foo;              // copy (foo still usable)

let coin = Coin { value: 0 }; // Coin doesn't have copy
let coin2 = coin;             // move (coin no longer usable)
```

### 2.4 Borrowing and References

```move
let foo = Foo { x: 3 };
let foo_ref: &Foo = &foo;           // Immutable reference
let x_ref: &u64 = &foo.x;           // Field reference

let x_mut: &mut u64 = &mut foo.x;   // Mutable reference
*x_mut = 42;                        // Modify through reference
```

---

## 3. Sui Object Model

### 3.1 Object Definition

In Sui, a struct with `key` ability and `id: UID` as first field is an object:

```move
public struct MyObject has key {
    id: UID,           // Must be the first field
    value: u64,
    data: vector<u8>,
}
```

### 3.2 Ownership Types

```
┌─────────────────────────────────────────────────────────────┐
│                    Sui Object Ownership Model               │
├─────────────────┬───────────────────────────────────────────┤
│ Address-owned   │ Only owner can access and modify          │
│ Shared          │ Anyone can access, supports mut/immut ref │
│ Immutable       │ Anyone can read, but cannot modify        │
│ Object-owned    │ Owned by another object                   │
└─────────────────┴───────────────────────────────────────────┘
```

### 3.3 Creating and Transferring Objects

```move
module book::transfer_to_sender {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    public struct AdminCap has key { id: UID }

    /// init function is called automatically when module is published
    fun init(ctx: &mut TxContext) {
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    /// Transfer AdminCap to new owner
    public fun transfer_admin_cap(cap: AdminCap, recipient: address) {
        transfer::transfer(cap, recipient);
    }
}
```

### 3.4 Shared Objects

```move
public struct Config has key {
    id: UID,
    message: String,
}

/// Create and share an object
public fun create_and_share(message: String, ctx: &mut TxContext) {
    let config = Config {
        id: object::new(ctx),
        message
    };
    transfer::share_object(config);
}
```

---

## 4. Storage Functions Reference

### 4.1 sui::transfer Module

```move
module sui::transfer {
    // Transfer object to recipient (only for types defined in same module)
    public fun transfer<T: key>(obj: T, recipient: address);
    
    // Public transfer (requires store ability)
    public fun public_transfer<T: key + store>(obj: T, recipient: address);
    
    // Share object
    public fun share_object<T: key>(obj: T);
    public fun public_share_object<T: key + store>(obj: T);
    
    // Freeze as immutable
    public fun freeze_object<T: key>(obj: T);
    public fun public_freeze_object<T: key + store>(obj: T);
    
    // Receive object
    public fun public_receive<T: key + store>(
        parent: &mut UID, 
        to_receive: Receiving<T>
    ): T;
}
```

### 4.2 transfer vs public_transfer

| Function | Requirement | Use Case |
|----------|-------------|----------|
| `transfer` | Only `key` | Types defined in same module |
| `public_transfer` | `key + store` | Types from any module |

---

## 5. Dynamic Fields

### 5.1 Basic Usage

```move
use sui::dynamic_field as df;

public struct Parent has key {
    id: UID,
}

// Add dynamic field
df::add(&mut parent.id, b"key", value);

// Check existence
df::exists_(&parent.id, b"key");

// Borrow field
let val: &T = df::borrow(&parent.id, b"key");
let val_mut: &mut T = df::borrow_mut(&mut parent.id, b"key");

// Remove field
let val: T = df::remove(&mut parent.id, b"key");
```

### 5.2 Account Balance Management Example

```move
module examples::account {
    use sui::dynamic_field as df;
    use sui::coin::Coin;

    public struct Account has key {
        id: UID,
    }

    public struct AccountBalance<phantom T> has copy, drop, store {}

    public fun accept_payment<T>(account: &mut Account, coin: Coin<T>) {
        let balance_key = AccountBalance<T>{};
        
        if (df::exists_(&account.id, balance_key)) {
            let balance: &mut Coin<T> = df::borrow_mut(&mut account.id, balance_key);
            balance.join(coin);
        } else {
            df::add(&mut account.id, balance_key, coin);
        }
    }
}
```

---

## 6. Programmable Transaction Blocks (PTB)

### 6.1 Concept

PTBs allow combining multiple commands in a single transaction:
- Call multiple Move functions
- Manage objects
- Split/merge coins

### 6.2 TypeScript SDK Example

```typescript
import { Transaction } from '@mysten/sui/transactions';

const tx = new Transaction();

// Split coins
const [coin] = tx.splitCoins(tx.gas, [tx.pure('u64', 100)]);

// Transfer objects
tx.transferObjects([coin], tx.pure('address', '0xRecipient'));

// Execute transaction
client.signAndExecuteTransaction({ signer: keypair, transaction: tx });
```

### 6.3 CLI Commands

```bash
# Split coins
sui client ptb --split-coins gas [1000, 5000, 75000]

# Merge coins
sui client ptb --merge-coins @coin_id [@coin1, @coin2]

# Transfer objects
sui client ptb --transfer-objects [obj1, obj2] @recipient
```

---

## 7. Module Initialization and OTW

### 7.1 init Function

```move
fun init(ctx: &mut TxContext) {
    // Automatically executed when module is published
    // Used for initialization setup
}
```

### 7.2 One Time Witness (OTW)

```move
module book::publisher {
    use sui::package::{Self, Publisher};

    /// OTW struct: module name in uppercase, only has drop ability
    public struct PUBLISHER has drop {}

    fun init(otw: PUBLISHER, ctx: &mut TxContext) {
        let publisher: Publisher = sui::package::claim(otw, ctx);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
    }
}
```

OTW Characteristics:
- Struct name is module name in uppercase
- Only has `drop` ability
- First parameter of init function
- Guaranteed to be created only once during module publication

---

## 8. Testing

### 8.1 Unit Tests

```move
#[test]
fun test_create_object() {
    let obj = create(42, b"test");
    assert!(obj.value == 42, 0);
}

#[test]
#[expected_failure(abort_code = 1)]
fun test_should_fail() {
    abort 1
}
```

### 8.2 Running Tests

```bash
# Run all tests
sui move test

# Run specific test
sui move test test_create_object

# Verbose output
sui move test --verbose
```

---

## 9. Contract Upgrades

### 9.1 Upgrade Strategies

1. **Compatible Upgrade**: Only add new features, don't modify existing interfaces
2. **Migration Upgrade**: Major changes requiring data migration
3. **Version Control**: Use version numbers to manage different versions

### 9.2 Upgrade Best Practices

- Maintain backward compatibility
- Use version check scripts
- Test upgrade paths
- Document changes

---

## 10. Error Handling

### 10.1 Error Code Definition

```move
const ENotOwner: u64 = 0;
const EInsufficientBalance: u64 = 1;
const EInvalidInput: u64 = 2;

public fun withdraw(account: &mut Account, amount: u64, ctx: &TxContext) {
    assert!(account.owner == tx_context::sender(ctx), ENotOwner);
    assert!(account.balance >= amount, EInsufficientBalance);
    // ...
}
```

### 10.2 Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| Object not found | Object deleted or transferred | Check object ID |
| Permission denied | Non-owner operation | Verify caller identity |
| Insufficient gas | High transaction complexity | Increase gas budget |
