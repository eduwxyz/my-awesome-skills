---
name: tdd
version: 2.0.0
description: Drives feature work and bug fixes through a tight failing-test-first loop. Trigger when implementing, fixing, or refactoring behavior in a codebase that already has tests. Skip for spikes, visual-only edits, throwaway scripts, and generated files.
---

# TDD

One small failing test, just enough code to pass, then a look. Repeat.

## Install

Drop in `~/.claude/skills/tdd/` (per-user) or `<repo>/.claude/skills/tdd/` (per-project).

## Skip TDD for

Spikes, copy/style/visual edits, one-off scripts, generated files. If the codebase has no tests at all, see [untested-code.md](untested-code.md) first.

## Two rules that keep TDD honest

1. **Never start a second test before the first one passes.**
2. **Never edit production code while red, except to make red green.**

If either slips, back up.

## What a good test looks like

The name describes a capability, not a method. Read it out loud — it should sound like something a user or caller would care about.

```
✅ logged_out_user_cannot_publish_a_post
✅ schedule_overlap_returns_409

❌ post_service_calls_repo_save
❌ schedule_returns_object_with_status
```

The body has three sections in order — set up, do the thing, check what's observed:

```
test "expired tokens are rejected":
  token = issue_token(ttl_seconds: 60)
  advance_clock(seconds: 120)

  result = verify(token)

  assert result.ok == false
  assert result.reason == "expired"
```

If renaming a private function tomorrow would break the test even though no behavior changed, the test was tied to internals. Rewrite or delete it. See [test-anatomy.md](test-anatomy.md).

## The cardinal mistake: tests in bulk

Writing five tests up front and then five implementations produces tests that describe an *imagined* system. They lock you into the wrong shape and stop pulling their weight once any pair shares a code path.

Each test must exist because of something you learned writing the previous one.

```
Wrong:  RED  t1 t2 t3 t4 t5    →   GREEN  c1 c2 c3 c4 c5
Right:  t1→c1, t2→c2, t3→c3, ...
```

Same mistake in miniature: writing one test and reaching inside to "also handle" something it doesn't cover. Don't.

## The cycle

**1. Decide.** If a `spec/<slug>.md` exists for this task, read it — Behaviors + Acceptance criteria are your queue. Otherwise list the behaviors to verify in rough order with whoever cares.

**2. Smoke run.** Pick the first behavior. Test → fails → minimum code → passes. If this first cycle takes more than 15 minutes, the slice is too big.

**3. Each next behavior.** Same shape. One test at a time. No speculation. No "while I'm here." If a rule slips, see [smells.md](smells.md#warning-signs-while-you-work).

**4. Cleanup.** Tests green? See [cleanup.md](cleanup.md). Cleanup only on green; never add behavior during cleanup.

## When you're done

Stop adding tests when all are true:

- Every acceptance criterion has a test.
- Every interesting branch has a test (skip getters, plumbing).
- The domain edge cases (empty input, expired things, races, boundaries) are covered.
- Reading just the test file would teach the feature.

100% coverage with bad tests is worse than 70% with good ones.

## Per-cycle checklist

- [ ] Test names a capability, not a method.
- [ ] Test only touches the public API.
- [ ] Test would survive a rename of internals.
- [ ] Code written is the minimum for this test.
- [ ] No second test queued before this one is green.

## Map

- [test-anatomy.md](test-anatomy.md) — body shape, assertions per test, naming.
- [smells.md](smells.md) — bad-test patterns + warning signs while you work or review.
- [boundaries.md](boundaries.md) — mocks, fakes, stubs; what counts as an edge.
- [untested-code.md](untested-code.md) — TDD on legacy.
- [shape.md](shape.md) — deep modules + designing for tests.
- [cleanup.md](cleanup.md) — what to do after green.
