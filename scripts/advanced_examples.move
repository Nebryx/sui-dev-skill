# Advanced contract examples

// Events example
module mypackage::events_example {
    struct Event has store {
        message: vector<u8>,
    }

    public fun emit_event(message: vector<u8>) {
        let event = Event { message };
        // Typically this would call event::emit or similar
    }
}

// Generics example
module mypackage::generics_example {
    struct Wrapper<T> has copy, drop, store {
        value: T,
    }

    public fun wrap<T>(val: T): Wrapper<T> {
        Wrapper { value: val }
    }
}

// Witness pattern example
module mypackage::witness_example {
    struct Witness has key {}

    public fun verify_witness(w: &Witness) {
        // Verify witness logic
    }
}

// Usage:
// let w = Witness {};
// verify_witness(&w);
