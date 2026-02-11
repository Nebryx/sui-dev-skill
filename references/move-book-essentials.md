# Move Book Essentials

This guide condenses high-impact language rules from Move Book for day-to-day coding and review.

## 1. Modules and Packages

- Modules are defined as `module <address>::<name> { ... }` and are namespaced by address.
- The source file name should match the module name and end with `.move`.
- Move packages are described by `Move.toml` and can declare named addresses for safer reuse.
- In package dependencies, `override = true` can replace transitive versions if needed.

Primary references:
- https://move-book.com/reference/modules/
- https://move-book.com/reference/packages/

## 2. Structs, Abilities, and Resources

- Struct abilities (`copy`, `drop`, `store`, `key`) define legal operations and storage behavior.
- Abilities are compositional: a struct can only have abilities compatible with its fields.
- In Sui, top-level objects use `key` and `id: UID` as the first field.
- Use `store` when values must be embedded/transferred publicly.

Primary references:
- https://move-book.com/reference/structs/
- https://move-book.com/reference/abilities/

## 3. References and Borrowing Rules

- References are non-storable and cannot outlive function boundaries.
- `&T` allows reads; `&mut T` allows mutation with exclusive access semantics.
- Copying through a reference requires `copy`; moving through references is restricted.
- Design APIs to minimize mutable borrows and shorten borrow scope.

Primary reference:
- https://move-book.com/reference/primitive-types/references/

## 4. Generics and Type Design

- Use generics to avoid duplication and encode type-safe abstractions.
- Add ability constraints to generic types/functions when operations require them.
- Use `phantom` type parameters for compile-time tagging without runtime storage cost.

Primary reference:
- https://move-book.com/reference/generics/

## 5. Visibility and Imports

- Visibility forms include module-private, `public`, and package-restricted visibility.
- Keep state-mutating functions minimally exposed; publish read APIs intentionally.
- Use `use` and aliases to keep paths readable and avoid repetitive fully-qualified names.

Primary references:
- https://move-book.com/move-basics/visibility/
- https://move-book.com/reference/uses/

## 6. Error Handling and Testing

- Use `abort`/`assert!` with explicit error codes for deterministic failure behavior.
- Prefer stable error code constants (`E...`) for auditability.
- Use `#[test]`, `#[expected_failure(...)]`, and `#[test_only]` to validate both success and failure paths.
- Keep tests focused on invariants: ownership, permissions, and state transitions.

Primary references:
- https://move-book.com/reference/abort-and-assert/
- https://move-book.com/reference/unit-testing/

## 7. Practical Review Checklist

- Are abilities minimal and correct for each struct?
- Are mutable borrows scoped tightly and not leaked across complex blocks?
- Are public APIs intentionally exposed and permission-checked?
- Are abort codes explicit and covered by failure tests?
- Is package/address configuration reproducible via `Move.toml`?
