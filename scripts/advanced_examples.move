// Extended Move module with dynamic fields example
module mypackage::advanced_examples {
    struct DynamicFieldExample has key {
        id: u64,
        data: vector<u8>,
    }

    public fun create_example(id: u64, data: vector<u8>): DynamicFieldExample {
        DynamicFieldExample { id, data }
    }

    #[test]
    public fun test_dynamic_field_example() {
        let example = create_example(1, b"example_data".to_vector());
        assert!(example.id == 1, 0);
        assert!(example.data == b"example_data".to_vector(), 1);
    }
}
