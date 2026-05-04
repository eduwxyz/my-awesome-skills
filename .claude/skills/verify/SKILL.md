---
name: verify
description: Verify that a spec.md's Acceptance criteria are observably covered by green tests before opening a PR. Reads the spec, finds the tests that cover each AC, runs the suite to confirm everything green, and reports gaps (uncovered AC, skipped tests, missing edge-case coverage). When gaps exist, automatically iterates with `tdd` until the spec is satisfied — does not stop while gaps remain. Surfaces tests not mapping to any AC as warnings (no auto-fix; user decides). Trigger after `tdd` is green and before sending the work for review, when the user says "verify the spec", "are we done", "check coverage against spec", "ready for review", "is this PR-ready".
hooks:
  Stop:
    - hooks:
        - type: command
          command: "bash ./hooks/iteration-gate.sh"
---

# Verify

The closing gate of the SDD pipeline. Map every acceptance criterion in the spec to a green test, surface any gaps, decide whether the work is ready for review.

## Skip verify for

- **Spike / scratch work** — there's no spec to verify against.
- **Tiny obvious changes** — typo fix, single-line bug, comment update.
- **Specs without an `## Acceptance criteria` section** — the upstream skill (`interview-to-spec` or `diagnose`) was abandoned mid-way. Finish that first.

## Before you start

**Identify the spec.** A path or slug for an existing `spec/<slug>.md`. If neither was provided, ask the user — do not guess.

**Validate it.** The spec must contain `## Acceptance criteria`. If missing, abort and tell the user to complete the spec first.

## The work

1. **Read the spec.** Focus on `Acceptance criteria` and `Edge cases` (or `Related risks` for bug specs).

2. **Find the tests.** Locate the relevant test files in the project's test directory (`tests/`, `__tests__/`, `*_test.go`, `*_spec.rb`, etc). Read them.

3. **Map AC → test.** For each acceptance criterion, find the test that **observably proves it**. Match on behaviour, not on naming similarity. A test named close to an AC does not count if it asserts something different.

4. **Find gaps.** Two categories — handled differently:

   **Blocking gaps** (auto-fixed via handoff to `tdd`):
   - An AC (or edge case) with no test covering it.
   - A test marked `skip` / `xfail` / `it.skip` / `@pytest.mark.skip` / `t.Skip` / equivalent.
   - A test with `TODO`, commented-out assertions, or empty body.
   - An edge case from the spec without observable coverage.

   **Warnings** (surface only, do **not** auto-fix):
   - Tests that don't trace back to any AC or edge case in the spec. They might be intentional extra coverage or scope creep — that's the user's call. Listed in the report; do not affect the verdict.

5. **Confirm green.** Run the project's test command (from `.claude/tdd/test-command.txt` if it exists, otherwise infer it the same way the `tdd` skill does). All tests must pass.

6. **Report and persist the verdict.** Use the format below, and write the one-word verdict to `.claude/verify/last-verdict.txt` (see *Persisting the verdict*).

## Output format

```markdown
## Verify report — <slug>

### Acceptance criteria coverage
- ✅ AC1 — `tests/auth/test_token.py::test_expired_tokens_rejected`
- ✅ AC2 — `tests/auth/test_token.py::test_valid_tokens_accepted`
- ❌ AC3 — no test found

### Edge cases
- ✅ Empty input — `tests/auth/test_token.py::test_empty_token_returns_400`
- ❌ Concurrent refresh — no test

### Tests without spec mapping (warning — your call)
- ⚠️ `tests/auth/test_token.py::test_token_internal_repr` — does not map to any AC. Intentional extra coverage, or scope-creep test to delete?

### Test run
✅ 47 passed, 0 failed, 0 skipped.

### Verdict
**Not ready.** 2 items lack coverage. See gaps above.
```

When all blocking gaps are absent and the suite is green, the verdict is **Ready for review.** Tests-without-mapping warnings do **not** affect the verdict.

## Persisting the verdict

Every run of `verify` ends by writing the one-word verdict to `.claude/verify/last-verdict.txt` (create the directory if missing). The file is a single line, no trailing newline:

- `Ready` — all blocking gaps resolved and the suite is green.
- `Not ready` — at least one blocking gap remains.

The Stop hook reads this file. If you forget to write it, the previous run's verdict persists; if you never write it, the hook never blocks. **Always overwrite at the end of every run.**

## Where this skill ends

- **Verdict = Ready for review** → hand off to `review` (built-in) or proceed to PR.
- **Verdict = Not ready** → **DO NOT END THE TURN.** Immediately hand off to `tdd` with the gap list as the new test queue. After `tdd` is green, re-invoke `verify`. Repeat until the verdict is `Ready`.

The Stop hook **forces this iteration**: while the verdict file says `Not ready`, the turn cannot end. Do not try to skip the loop — fix the gaps via `tdd`, re-verify, repeat.

Do not try to fix gaps inside `verify` itself — that's `tdd`'s job. Verify only inspects, iterates, and reports.
