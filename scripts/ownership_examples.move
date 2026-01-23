// Object Ownership and Transfer Examples for Sui Move
// Demonstrates different ownership patterns and transfer mechanisms

module mypackage::ownership_examples {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // ============ Address-Owned Objects ============

    /// An object owned by a specific address
    public struct OwnedObject has key, store {
        id: UID,
        data: vector<u8>,
    }

    /// Create an address-owned object
    public fun create_owned(data: vector<u8>, recipient: address, ctx: &mut TxContext) {
        let obj = OwnedObject {
            id: object::new(ctx),
            data,
        };
        // Only recipient can access this object
        transfer::transfer(obj, recipient);
    }

    /// Transfer ownership to a new address
    public fun transfer_owned(obj: OwnedObject, new_owner: address) {
        transfer::transfer(obj, new_owner);
    }

    // ============ Shared Objects ============

    /// A shared object accessible by anyone
    public struct SharedConfig has key {
        id: UID,
        value: u64,
        admin: address,
    }

    /// Create and share a config object
    public fun create_shared_config(value: u64, ctx: &mut TxContext) {
        let config = SharedConfig {
            id: object::new(ctx),
            value,
            admin: tx_context::sender(ctx),
        };
        // Anyone can access this object after sharing
        transfer::share_object(config);
    }

    /// Update shared config (anyone can call, but we check admin)
    public fun update_shared_config(config: &mut SharedConfig, new_value: u64, ctx: &TxContext) {
        assert!(config.admin == tx_context::sender(ctx), 0); // ENotAdmin
        config.value = new_value;
    }

    /// Read shared config value (anyone can read)
    public fun get_config_value(config: &SharedConfig): u64 {
        config.value
    }

    // ============ Immutable Objects ============

    /// An immutable configuration that cannot be changed
    public struct ImmutableConfig has key {
        id: UID,
        name: vector<u8>,
        version: u64,
    }

    /// Create and freeze an immutable config
    public fun create_immutable_config(
        name: vector<u8>, 
        version: u64, 
        ctx: &mut TxContext
    ) {
        let config = ImmutableConfig {
            id: object::new(ctx),
            name,
            version,
        };
        // Object becomes immutable - anyone can read, no one can modify
        transfer::freeze_object(config);
    }

    // ============ Capability Pattern ============

    /// Admin capability - grants special permissions
    public struct AdminCap has key, store {
        id: UID,
    }

    /// Treasury that requires AdminCap to withdraw
    public struct Treasury has key {
        id: UID,
        balance: u64,
    }

    /// Initialize module with admin cap and treasury
    fun init(ctx: &mut TxContext) {
        // Create and transfer admin capability to deployer
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, tx_context::sender(ctx));

        // Create and share treasury
        let treasury = Treasury {
            id: object::new(ctx),
            balance: 0,
        };
        transfer::share_object(treasury);
    }

    /// Deposit to treasury (anyone can deposit)
    public fun deposit(treasury: &mut Treasury, amount: u64) {
        treasury.balance = treasury.balance + amount;
    }

    /// Withdraw from treasury (requires AdminCap)
    public fun withdraw(
        _admin_cap: &AdminCap, 
        treasury: &mut Treasury, 
        amount: u64
    ): u64 {
        assert!(treasury.balance >= amount, 1); // EInsufficientBalance
        treasury.balance = treasury.balance - amount;
        amount
    }

    /// Transfer admin capability to new admin
    public fun transfer_admin(admin_cap: AdminCap, new_admin: address) {
        transfer::transfer(admin_cap, new_admin);
    }

    // ============ Public Transfer (with store ability) ============

    /// Object with store ability can be transferred by anyone
    public struct TransferableItem has key, store {
        id: UID,
        name: vector<u8>,
    }

    /// Create a transferable item
    public fun create_transferable(name: vector<u8>, ctx: &mut TxContext): TransferableItem {
        TransferableItem {
            id: object::new(ctx),
            name,
        }
    }

    /// Anyone can transfer this item using public_transfer
    /// because it has the `store` ability
    public fun send_item(item: TransferableItem, recipient: address) {
        transfer::public_transfer(item, recipient);
    }
}

// ============ Usage Examples ============
// 
// 1. Address-Owned: Only owner can use
//    sui client call --function create_owned --args "0x..." @recipient
//
// 2. Shared: Anyone can access
//    sui client call --function update_shared_config --args @config_id 100
//
// 3. Immutable: Read-only access
//    Object can be passed as immutable reference to any function
//
// 4. Capability: Permission-based access
//    Must own AdminCap to call withdraw
