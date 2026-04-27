# Cleanup After Green

Look for these:

- **Duplication** — same transformation in three places. Extract. (Wait for three; two might be coincidence.)
- **Long methods** — extract private helpers; keep tests on the public surface.
- **Shallow modules** — combine, or move complexity behind a smaller surface. See [shape.md](shape.md).
- **Feature envy** — a method that uses another object more than its own data. Move it.
- **Primitive obsession** — `string` for an email, `int` for a price. Introduce a type.
- **Conditional creep** — an `if`/`switch` chain that grows every PR. Replace with polymorphism, lookup table, or strategy.
- **Boolean parameters** — `do_thing(x, true, false)`. Name them, or split into separate functions.
- **Existing code the new code reveals as wrong** — fix it now if local; otherwise note it and ship.

## Two strict rules

1. Cleanup only on green.
2. No new behavior during cleanup. Spot a missing case, write it down, come back after.

## Moves that look safe but aren't

- **Renaming across files** — IDEs miss stringly-typed references (config, SQL columns, dynamic dispatch). Grep wider.
- **Removing "unused" code** — search the whole monorepo. Reflective callers are common.
- **Inlining a one-call function** — check git blame; someone may have extracted it expecting it to grow.

Stop refactoring when the code reads top-to-bottom and the next change would touch tests that aren't failing. Ship.
