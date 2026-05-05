# Untested Code

Pure TDD assumes a tested codebase. Most real work happens without one. Two phases: **pin first, then change**.

## Phase 1: pin current behavior

Write tests that capture what the code does today — even parts that look wrong. Goal: a regression net.

```
test "format_amount returns unrounded for zero (current behavior, looks like a bug)":
  assert format_amount(0) == "0.0000"
```

How:
1. Pick the smallest piece you can run end-to-end without restructuring.
2. Feed it inputs you can construct as-is.
3. Capture the actual output as the expected value.
4. Don't judge. Bizarre output is the spec until you decide otherwise.

Tag these (`pin_…`, `@pinned`) so you can find them when it's time to delete or rewrite.

## Phase 2: TDD on top

With pin tests green:

- **Adding behavior** — TDD as usual; pin tests catch regressions.
- **Fixing a bug** — write a test that fails the way the bug fails; fix; if a pin test contradicts the fix, update or delete it in the same commit.
- **Refactoring** — pin tests are the safety net. Break = behavior changed = back out.

## Creating a seam without changing behavior

When the code has nowhere to test through:

- **Lift a dependency to a parameter with a default** — `function foo(input, clock = real_clock)`. Production keeps calling `foo(input)`.
- **Sprout a method** — pull the new logic into a fresh function; old function calls into it.
- **Wrap** — thin adapter with the interface you wish the legacy had.
- **Subclass-and-override** — last resort, couples test to internals.

## Don'ts

- Don't characterize the whole system. Pin only what you'll touch.
- Don't refactor without pin tests. Especially not "obvious cosmetic" ones.
- Don't try to make legacy beautiful in one PR. Pin → change → ship. Repeat.

Reference: Michael Feathers, *Working Effectively with Legacy Code*.
