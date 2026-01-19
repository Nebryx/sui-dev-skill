# Move module unit test example

module mypackage::test_example {
    #[test]
    fun test_create() {
        let obj = mypackage::ownership_example::create(42, b"test");
        assert!(obj.id == 42, 1);
    }

    #[test]
    fun test_transfer() {
        let obj = mypackage::ownership_example::create(7, b"data");
        mypackage::ownership_example::transfer(obj, @0x456);
        // No assert here, just testing transfer does not panic
    }
}

# Command to run tests
# sui move test --path .
