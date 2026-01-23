// Advanced Sui Move Examples
// Demonstrates dynamic fields, events, generics, and OTW pattern

module mypackage::advanced_examples {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;
    use sui::event;
    use sui::package::{Self, Publisher};

    // ============ Error Codes ============
    const EFieldNotFound: u64 = 0;
    const ENotAuthorized: u64 = 1;

    // ============ Dynamic Fields Example ============

    /// Container object that can hold dynamic fields
    public struct Container has key {
        id: UID,
        name: vector<u8>,
    }

    /// Key type for string-keyed dynamic fields
    public struct StringKey has copy, drop, store {
        key: vector<u8>,
    }

    /// Create a new container
    public fun create_container(name: vector<u8>, ctx: &mut TxContext): Container {
        Container {
            id: object::new(ctx),
            name,
        }
    }

    /// Add a dynamic field to container
    public fun add_field<V: store>(
        container: &mut Container,
        key: vector<u8>,
        value: V
    ) {
        let field_key = StringKey { key };
        df::add(&mut container.id, field_key, value);
    }

    /// Get a dynamic field value (immutable)
    public fun get_field<V: store>(container: &Container, key: vector<u8>): &V {
        let field_key = StringKey { key };
        assert!(df::exists_(&container.id, field_key), EFieldNotFound);
        df::borrow(&container.id, field_key)
    }

    /// Get a dynamic field value (mutable)
    public fun get_field_mut<V: store>(container: &mut Container, key: vector<u8>): &mut V {
        let field_key = StringKey { key };
        assert!(df::exists_(&container.id, field_key), EFieldNotFound);
        df::borrow_mut(&mut container.id, field_key)
    }

    /// Remove a dynamic field
    public fun remove_field<V: store>(container: &mut Container, key: vector<u8>): V {
        let field_key = StringKey { key };
        assert!(df::exists_(&container.id, field_key), EFieldNotFound);
        df::remove(&mut container.id, field_key)
    }

    /// Check if field exists
    public fun has_field(container: &Container, key: vector<u8>): bool {
        let field_key = StringKey { key };
        df::exists_(&container.id, field_key)
    }

    // ============ Events Example ============

    /// Event emitted when an item is created
    public struct ItemCreated has copy, drop {
        item_id: address,
        creator: address,
        value: u64,
    }

    /// Event emitted when an item is transferred
    public struct ItemTransferred has copy, drop {
        item_id: address,
        from: address,
        to: address,
    }

    /// Item that emits events
    public struct TrackedItem has key, store {
        id: UID,
        value: u64,
    }

    /// Create item and emit event
    public fun create_tracked_item(value: u64, ctx: &mut TxContext): TrackedItem {
        let item = TrackedItem {
            id: object::new(ctx),
            value,
        };
        
        // Emit creation event
        event::emit(ItemCreated {
            item_id: object::uid_to_address(&item.id),
            creator: tx_context::sender(ctx),
            value,
        });
        
        item
    }

    /// Transfer item and emit event
    public fun transfer_tracked_item(
        item: TrackedItem, 
        recipient: address, 
        ctx: &TxContext
    ) {
        let item_id = object::uid_to_address(&item.id);
        let from = tx_context::sender(ctx);
        
        // Emit transfer event
        event::emit(ItemTransferred {
            item_id,
            from,
            to: recipient,
        });
        
        transfer::public_transfer(item, recipient);
    }

    // ============ Generics Example ============

    /// Generic wrapper that can hold any type with store ability
    public struct Wrapper<T: store> has key, store {
        id: UID,
        content: T,
    }

    /// Wrap any value
    public fun wrap<T: store>(content: T, ctx: &mut TxContext): Wrapper<T> {
        Wrapper {
            id: object::new(ctx),
            content,
        }
    }

    /// Unwrap and get the content
    public fun unwrap<T: store>(wrapper: Wrapper<T>): T {
        let Wrapper { id, content } = wrapper;
        object::delete(id);
        content
    }

    /// Borrow content immutably
    public fun borrow_content<T: store>(wrapper: &Wrapper<T>): &T {
        &wrapper.content
    }

    /// Borrow content mutably
    public fun borrow_content_mut<T: store>(wrapper: &mut Wrapper<T>): &mut T {
        &mut wrapper.content
    }

    // ============ One Time Witness (OTW) Pattern ============

    /// OTW struct - module name in uppercase, only has drop
    public struct ADVANCED_EXAMPLES has drop {}

    /// Module initialization with OTW
    fun init(otw: ADVANCED_EXAMPLES, ctx: &mut TxContext) {
        // Claim publisher using OTW
        let publisher: Publisher = package::claim(otw, ctx);
        
        // Transfer publisher to deployer
        transfer::public_transfer(publisher, tx_context::sender(ctx));
    }

    // ============ Phantom Type Parameters ============

    /// Marker types for different token standards
    public struct USD {}
    public struct EUR {}

    /// Balance with phantom type for currency
    public struct Balance<phantom Currency> has store {
        value: u64,
    }

    /// Create a balance of specific currency
    public fun create_balance<Currency>(value: u64): Balance<Currency> {
        Balance { value }
    }

    /// Get balance value
    public fun balance_value<Currency>(balance: &Balance<Currency>): u64 {
        balance.value
    }

    /// Merge two balances of same currency
    public fun merge_balances<Currency>(
        balance1: &mut Balance<Currency>,
        balance2: Balance<Currency>
    ) {
        let Balance { value } = balance2;
        balance1.value = balance1.value + value;
    }

    // Type safety: Cannot merge USD with EUR
    // merge_balances<USD>(&mut usd_balance, eur_balance); // Compile error!

    // ============ Tests ============

    #[test]
    fun test_dynamic_fields() {
        use sui::test_scenario;
        
        let admin = @0xABCD;
        let mut scenario = test_scenario::begin(admin);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut container = create_container(b"test", ctx);
            
            // Add field
            add_field(&mut container, b"count", 42u64);
            
            // Check exists
            assert!(has_field(&container, b"count"), 0);
            
            // Get value
            let value = get_field<u64>(&container, b"count");
            assert!(*value == 42, 1);
            
            // Remove field
            let removed = remove_field<u64>(&mut container, b"count");
            assert!(removed == 42, 2);
            assert!(!has_field(&container, b"count"), 3);
            
            transfer::transfer(container, admin);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_generics() {
        use sui::test_scenario;
        
        let admin = @0xABCD;
        let mut scenario = test_scenario::begin(admin);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            
            // Wrap a u64
            let wrapped = wrap(100u64, ctx);
            assert!(*borrow_content(&wrapped) == 100, 0);
            
            // Unwrap
            let value = unwrap(wrapped);
            assert!(value == 100, 1);
        };
        
        test_scenario::end(scenario);
    }
}
