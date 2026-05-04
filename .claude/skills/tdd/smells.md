# Smells

Named patterns of bad tests, plus warning signs while you work. Use these names in code review.

## Bad-test patterns

**Bulk writing.** Many tests added before any implementation. Tests describe an imagined system. Fix: restart with one test → one impl.

**Coverage chasing.** Tests added to bump a number, not catch bugs. Tells: `test_constructor`, `test_getter`, "increases coverage" in PR description. Fix: delete them.

**Setup grows out of control.** Setup eclipses action+check. The system needs too much context, or a factory is missing. Fix: defaulting factory, or split the system.

**One test, several promises.** Multiple unrelated outcomes asserted in one body. Fix: one outcome per test.

**Name describes the code.** `test_calls_x`, `test_returns_y`, `test_uses_z`. Fix: rename to a capability.

**Mock leakage.** Asserting on call counts, args, or order to a mock instead of the real outcome. Fix: assert on what a caller observes; if you can't, the API needs an output the caller can see. See [boundaries.md](boundaries.md).

**Reaching for privates.** Test imports `_internal`, `@VisibleForTesting`, subclasses to peek. Fix: extract the internal into its own module with a real public surface.

**Asserting via the back door.** Test queries the DB / filesystem / cache directly. Fix: verify through the same surface a caller uses.

**Snapshot creep.** Snapshots of structured data (not rendered output) blindly `--update`d. Fix: snapshots only for actual rendered artefacts.

**Time bombs.** Hard-coded years, dates, "less than 30 days". Fix: inject a clock; compare deltas.

**Flake tolerance.** A test that fails 1% of the time and the team retries CI. Fix: fix the race or delete the test. No middle ground.

**Branching inside the test.** `if input.kind == "x": assert ... else: assert ...`. Fix: parametrize, or split into named tests.

**Decorative tests.** `assert setup() exists`. Fix: delete.

## Warning signs while you work

Stop and reconsider when:

- About to start a second test before the first passes.
- Adding an `if` for a case the current test doesn't exercise.
- A test has been red for more than ~10–15 minutes.
- You've opened a third file in the same cycle.
- Setup just hit ~20 lines.
- A refactor broke a test even though no behavior changed.
- Catching yourself thinking "while I'm here, let me also…"
- Test name starts with `test_calls_…`, `test_returns_…`, `test_uses_…`.
- The mock you're writing is bigger than the production code it stands in for.

## Warning signs in PR review

- Many tests, no implementation between them.
- Test imports a private symbol from the system under test.
- Mocks of types defined in the same package as the SUT.
- Setup chunks far larger than action+check.
- One test asserting on 4+ unrelated things.
- `expect(mock.x).called_with(...)` as the only assertion.
- Hard-coded dates, `sleep`/`setTimeout`, unseeded randomness.
- `if`/`switch` inside a test body.
- Leftover `.only`, `.skip`, `fdescribe`, `xtest`.
- Snapshot files changed by hundreds of lines under "updated snapshots."
- Tests querying the DB directly to verify.
