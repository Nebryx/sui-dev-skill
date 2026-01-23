// Sui Move Testing Examples
// Demonstrates unit testing patterns and test utilities

module mypackage::test_examples {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // ============ Module Under Test ============

    const EInvalidValue: u64 = 0;
    const ENotOwner: u64 = 1;

    public struct Counter has key {
        id: UID,
        value: u64,
        owner: address,
    }

    public fun create_counter(ctx: &mut TxContext): Counter {
        Counter {
            id: object::new(ctx),
            value: 0,
            owner: tx_context::sender(ctx),
        }
    }

    public fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1;
    }

    public fun increment_by(counter: &mut Counter, amount: u64) {
        counter.value = counter.value + amount;
    }

    public fun reset(counter: &mut Counter, ctx: &TxContext) {
        assert!(counter.owner == tx_context::sender(ctx), ENotOwner);
        counter.value = 0;
    }

    public fun get_value(counter: &Counter): u64 {
        counter.value
    }

    public fun destroy(counter: Counter) {
        let Counter { id, value: _, owner: _ } = counter;
        object::delete(id);
    }

    // ============ Basic Unit Tests ============

    #[test]
    fun test_create_counter() {
        use sui::test_scenario;
        
        let owner = @0x1;
        let mut scenario = test_scenario::begin(owner);
        
        // Create counter
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let counter = create_counter(ctx);
            assert!(get_value(&counter) == 0, 0);
            transfer::transfer(counter, owner);
        };
        
        // Verify counter exists
        test_scenario::next_tx(&mut scenario, owner);
        {
            let counter = test_scenario::take_from_sender<Counter>(&scenario);
            assert!(get_value(&counter) == 0, 1);
            test_scenario::return_to_sender(&scenario, counter);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_increment() {
        use sui::test_scenario;
        
        let owner = @0x1;
        let mut scenario = test_scenario::begin(owner);
        
        // Create and increment
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut counter = create_counter(ctx);
            
            increment(&mut counter);
            assert!(get_value(&counter) == 1, 0);
            
            increment(&mut counter);
            assert!(get_value(&counter) == 2, 1);
            
            increment_by(&mut counter, 10);
            assert!(get_value(&counter) == 12, 2);
            
            transfer::transfer(counter, owner);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_reset_by_owner() {
        use sui::test_scenario;
        
        let owner = @0x1;
        let mut scenario = test_scenario::begin(owner);
        
        // Create and modify
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut counter = create_counter(ctx);
            increment_by(&mut counter, 100);
            transfer::transfer(counter, owner);
        };
        
        // Reset as owner
        test_scenario::next_tx(&mut scenario, owner);
        {
            let mut counter = test_scenario::take_from_sender<Counter>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            reset(&mut counter, ctx);
            assert!(get_value(&counter) == 0, 0);
            
            test_scenario::return_to_sender(&scenario, counter);
        };
        
        test_scenario::end(scenario);
    }

    // ============ Expected Failure Tests ============

    #[test]
    #[expected_failure(abort_code = ENotOwner)]
    fun test_reset_by_non_owner_fails() {
        use sui::test_scenario;
        
        let owner = @0x1;
        let non_owner = @0x2;
        let mut scenario = test_scenario::begin(owner);
        
        // Create counter as owner
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let counter = create_counter(ctx);
            transfer::public_transfer(counter, owner);
        };
        
        // Try to reset as non-owner (should fail)
        test_scenario::next_tx(&mut scenario, non_owner);
        {
            // This would fail because non_owner doesn't own the counter
            // In real test, we'd need to transfer to non_owner first
            let ctx = test_scenario::ctx(&mut scenario);
            let mut counter = Counter {
                id: object::new(ctx),
                value: 100,
                owner: owner, // Owner is different from sender
            };
            
            // This should abort with ENotOwner
            reset(&mut counter, ctx);
            
            destroy(counter);
        };
        
        test_scenario::end(scenario);
    }

    // ============ Multi-Transaction Tests ============

    #[test]
    fun test_multi_user_scenario() {
        use sui::test_scenario;
        
        let alice = @0xA;
        let bob = @0xB;
        let mut scenario = test_scenario::begin(alice);
        
        // Alice creates counter
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let counter = create_counter(ctx);
            transfer::public_transfer(counter, alice);
        };
        
        // Alice increments
        test_scenario::next_tx(&mut scenario, alice);
        {
            let mut counter = test_scenario::take_from_sender<Counter>(&scenario);
            increment_by(&mut counter, 5);
            assert!(get_value(&counter) == 5, 0);
            
            // Transfer to Bob
            transfer::public_transfer(counter, bob);
        };
        
        // Bob increments
        test_scenario::next_tx(&mut scenario, bob);
        {
            let mut counter = test_scenario::take_from_sender<Counter>(&scenario);
            increment_by(&mut counter, 3);
            assert!(get_value(&counter) == 8, 1);
            test_scenario::return_to_sender(&scenario, counter);
        };
        
        test_scenario::end(scenario);
    }

    // ============ Shared Object Tests ============

    public struct SharedCounter has key {
        id: UID,
        value: u64,
    }

    public fun create_shared_counter(ctx: &mut TxContext) {
        let counter = SharedCounter {
            id: object::new(ctx),
            value: 0,
        };
        transfer::share_object(counter);
    }

    public fun increment_shared(counter: &mut SharedCounter) {
        counter.value = counter.value + 1;
    }

    #[test]
    fun test_shared_counter() {
        use sui::test_scenario;
        
        let admin = @0xADMIN;
        let user1 = @0x1;
        let user2 = @0x2;
        let mut scenario = test_scenario::begin(admin);
        
        // Admin creates shared counter
        {
            let ctx = test_scenario::ctx(&mut scenario);
            create_shared_counter(ctx);
        };
        
        // User1 increments
        test_scenario::next_tx(&mut scenario, user1);
        {
            let mut counter = test_scenario::take_shared<SharedCounter>(&scenario);
            increment_shared(&mut counter);
            assert!(counter.value == 1, 0);
            test_scenario::return_shared(counter);
        };
        
        // User2 increments
        test_scenario::next_tx(&mut scenario, user2);
        {
            let mut counter = test_scenario::take_shared<SharedCounter>(&scenario);
            increment_shared(&mut counter);
            assert!(counter.value == 2, 1);
            test_scenario::return_shared(counter);
        };
        
        test_scenario::end(scenario);
    }
}

// ============ Running Tests ============
// 
// Run all tests:
//   sui move test
//
// Run specific test:
//   sui move test test_create_counter
//
// Run with verbose output:
//   sui move test --verbose
//
// Run with gas profiling:
//   sui move test --gas-profiling
//
// Filter tests by pattern:
//   sui move test --filter "increment"
