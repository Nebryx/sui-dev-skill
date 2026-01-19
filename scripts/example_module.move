# Move module template example

module mypackage::example {
    struct MyStruct has key {
        value: u64,
    }

    public fun create(value: u64): MyStruct {
        MyStruct { value }
    }
}

# Build and deploy example script using Sui CLI
sui move build
sui client publish --gas-budget 10000
