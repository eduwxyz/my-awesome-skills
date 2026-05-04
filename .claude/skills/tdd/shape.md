# Module Shape

Two ideas that decide how easy your tests are to write.

## Deep modules

From Ousterhout's *A Philosophy of Software Design*.

**Deep** = small interface, lots of substance behind it.
**Shallow** = wide interface that barely does anything beyond passing values through.

Why it matters for TDD:

- Small surface → fewer tests needed.
- Substance behind a stable surface → internals can change without breaking tests.
- Shallow modules force a bad choice: many trivial tests, or tests that reach past the surface for something interesting.

When you find yourself wanting to test a private helper, ask whether it deserves to be its own deep module instead.

When **not** to deepen: domains that are inherently wide (SQL builder, math library). Don't force a small interface where the problem isn't small.

## Designing the public surface

Four moves that make a surface easy to test:

**1. Pass dependencies in; don't reach for them.**

```
# Testable
process_order(order, gateway)

# Welded to a specific implementation
process_order(order):
  gateway = StripeGateway()
```

**2. Return values; don't mutate inputs.** A function that returns a `Discount` is trivially testable; one that mutates `cart.total` requires inspecting state.

**3. Type by role, not by implementation.** The function takes a `UserRepo`, not a `PostgresUserRepo`. Production substitutes Postgres; tests substitute a fake. Same code path.

**4. Make impossible states impossible.** If `email` must be valid, give it a type that enforces validity at construction. The rest of the code doesn't need defensive checks; the test surface shrinks. Validation lives at the parser, not scattered across the system.
