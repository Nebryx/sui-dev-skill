# Sui Object Model Reference

## Overview

Sui uses an object-centric data model where everything is an object. This is fundamentally different from account-based blockchains and enables unique features like parallel transaction execution.

## Object Definition

An object in Sui is a struct with:
1. The `key` ability
2. `id: UID` as the first field

```move
public struct MyObject has key {
    id: UID,           // Required: unique identifier
    value: u64,        // Custom fields
    data: vector<u8>,
}
```

## Object Properties

### UID (Unique Identifier)

Every object has a globally unique ID that:
- Is generated at creation time
- Never changes during object's lifetime
- Is globally unique across all Sui objects

```move
use sui::object::{Self, UID};

// Create new UID
let id = object::new(ctx);

// Get address from UID
let addr = object::uid_to_address(&obj.id);

// Delete UID (required when destroying object)
object::delete(id);
```

## Ownership Types

### 1. Address-Owned Objects

Objects owned by a specific address. Only the owner can use them in transactions.

```move
public struct OwnedItem has key {
    id: UID,
    name: vector<u8>,
}

public fun create_owned(name: vector<u8>, ctx: &mut TxContext) {
    let item = OwnedItem {
        id: object::new(ctx),
        name,
    };
    // Transfer to sender - only they can access it
    transfer::transfer(item, tx_context::sender(ctx));
}
```

**Characteristics:**
- Single owner at any time
- Can be transferred to another address
- Enables parallel execution (no contention)
- Most common ownership type

### 2. Shared Objects

Objects accessible by anyone. Multiple transactions can access them.

```move
public struct SharedCounter has key {
    id: UID,
    value: u64,
}

public fun create_shared(ctx: &mut TxContext) {
    let counter = SharedCounter {
        id: object::new(ctx),
        value: 0,
    };
    // Share - anyone can access
    transfer::share_object(counter);
}

public fun increment(counter: &mut SharedCounter) {
    counter.value = counter.value + 1;
}
```

**Characteristics:**
- No single owner
- Anyone can access (read or write)
- Requires consensus for ordering
- Cannot be transferred or unshared

### 3. Immutable Objects

Objects that can never be modified. Anyone can read them.

```move
public struct ImmutableConfig has key {
    id: UID,
    version: u64,
    settings: vector<u8>,
}

public fun create_immutable(
    version: u64, 
    settings: vector<u8>, 
    ctx: &mut TxContext
) {
    let config = ImmutableConfig {
        id: object::new(ctx),
        version,
        settings,
    };
    // Freeze - becomes immutable forever
    transfer::freeze_object(config);
}
```

**Characteristics:**
- Cannot be modified after freezing
- Anyone can read
- Enables parallel reads
- Cannot be unfrozen

### 4. Object-Owned Objects

Objects owned by another object (wrapped or child objects).

```move
public struct Parent has key {
    id: UID,
    child: Child,  // Wrapped object
}

public struct Child has store {
    value: u64,
}

// Child is wrapped inside Parent
public fun create_with_child(ctx: &mut TxContext) {
    let child = Child { value: 0 };
    let parent = Parent {
        id: object::new(ctx),
        child,
    };
    transfer::transfer(parent, tx_context::sender(ctx));
}
```

## Object Abilities

### Required Abilities

| Ability | Required For |
|---------|--------------|
| `key` | Being an object (top-level storage) |
| `store` | Being wrapped in another object |
| `store` | Using `public_transfer`, `public_share_object` |

### Common Patterns

```move
// Object that can be transferred by anyone
public struct TransferableItem has key, store {
    id: UID,
    data: vector<u8>,
}

// Object that can only be transferred by defining module
public struct RestrictedItem has key {
    id: UID,
    data: vector<u8>,
}

// Value that can be stored in objects but isn't an object itself
public struct StorableData has store {
    value: u64,
}
```

## Transfer Functions

### Module-Restricted Transfer

```move
// Only works for types defined in the same module
transfer::transfer<T: key>(obj: T, recipient: address);
transfer::share_object<T: key>(obj: T);
transfer::freeze_object<T: key>(obj: T);
```

### Public Transfer

```move
// Works for any type with key + store
transfer::public_transfer<T: key + store>(obj: T, recipient: address);
transfer::public_share_object<T: key + store>(obj: T);
transfer::public_freeze_object<T: key + store>(obj: T);
```

## Receiving Objects

Objects can be sent to other objects and received later:

```move
use sui::transfer::Receiving;

public struct Mailbox has key {
    id: UID,
}

// Receive an object sent to the mailbox
public fun receive_item<T: key + store>(
    mailbox: &mut Mailbox,
    receiving: Receiving<T>
): T {
    transfer::public_receive(&mut mailbox.id, receiving)
}
```

## Object Lifecycle

```
┌─────────────┐
│   Create    │  object::new(ctx)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Owned     │  transfer::transfer()
└──────┬──────┘
       │
       ├──────────────┬──────────────┐
       ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  Transfer   │ │   Share     │ │   Freeze    │
│  (Owned)    │ │  (Shared)   │ │ (Immutable) │
└──────┬──────┘ └─────────────┘ └─────────────┘
       │              │              │
       ▼              │              │
┌─────────────┐       │              │
│   Delete    │◄──────┴──────────────┘
│ (Destroy)   │  (Only owned objects can be deleted)
└─────────────┘
```

## Destroying Objects

Objects must be explicitly destroyed:

```move
public fun destroy(obj: MyObject) {
    let MyObject { id, value: _, data: _ } = obj;
    object::delete(id);  // Required to delete UID
}
```

## Best Practices

1. **Choose Ownership Wisely**
   - Use owned objects for user assets
   - Use shared objects for global state
   - Use immutable objects for configuration

2. **Minimize Shared Objects**
   - Shared objects require consensus
   - Can become bottlenecks
   - Consider owned alternatives

3. **Use store Ability Carefully**
   - Enables public transfer
   - Consider if you want external control

4. **Handle Object Deletion**
   - Always provide destroy functions
   - Properly unpack and delete UID

5. **Consider Wrapping**
   - Wrap related objects together
   - Reduces transaction complexity
