# Object ownership and transfer example scripts

# Define a simple object with ownership capabilities
module mypackage::ownership_example {
    use sui::transfer::transfer;

    struct OwnedObject has key {
        id: u64,
        data: vector<u8>,
    }

    public fun create(id: u64, data: vector<u8>): OwnedObject {
        OwnedObject { id, data }
    }

    public fun transfer(obj: OwnedObject, new_owner: address) {
        transfer(obj, new_owner);
    }
}

# Transaction script demonstrating object creation and transfer
script {
    use mypackage::ownership_example::{create, transfer};

    fun main() {
        let obj = create(1, b"hello");
        transfer(obj, @0x123);
    }
}
