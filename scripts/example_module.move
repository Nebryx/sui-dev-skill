// Basic Move module template for Sui
// This demonstrates the standard structure of a Sui Move module

module mypackage::example {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// A simple object with key ability
    /// First field must be `id: UID` for all objects
    public struct MyObject has key, store {
        id: UID,
        value: u64,
    }

    /// Module initialization - called once when module is published
    fun init(ctx: &mut TxContext) {
        let obj = MyObject {
            id: object::new(ctx),
            value: 0,
        };
        // Transfer to the publisher
        transfer::transfer(obj, tx_context::sender(ctx));
    }

    /// Create a new MyObject and transfer to recipient
    public fun create(value: u64, recipient: address, ctx: &mut TxContext) {
        let obj = MyObject {
            id: object::new(ctx),
            value,
        };
        transfer::transfer(obj, recipient);
    }

    /// Create and return a new MyObject (for composability)
    public fun create_owned(value: u64, ctx: &mut TxContext): MyObject {
        MyObject {
            id: object::new(ctx),
            value,
        }
    }

    /// Get the value of an object
    public fun get_value(obj: &MyObject): u64 {
        obj.value
    }

    /// Update the value of an object
    public fun set_value(obj: &mut MyObject, new_value: u64) {
        obj.value = new_value;
    }

    /// Delete an object
    public fun destroy(obj: MyObject) {
        let MyObject { id, value: _ } = obj;
        object::delete(id);
    }

    // ============ Test Functions ============

    #[test]
    fun test_create_and_get_value() {
        use sui::test_scenario;
        
        let admin = @0xABCD;
        let mut scenario = test_scenario::begin(admin);
        
        // Create object
        {
            let ctx = test_scenario::ctx(&mut scenario);
            create(42, admin, ctx);
        };
        
        // Verify object
        test_scenario::next_tx(&mut scenario, admin);
        {
            let obj = test_scenario::take_from_sender<MyObject>(&scenario);
            assert!(get_value(&obj) == 42, 0);
            test_scenario::return_to_sender(&scenario, obj);
        };
        
        test_scenario::end(scenario);
    }
}

// ============ CLI Commands ============
// Build: sui move build
// Test: sui move test
// Publish: sui client publish --gas-budget 100000000
