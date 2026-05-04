---
name: diagnose
description: Turn a bug symptom into a fix with a regression test that locks it down. If the user opens vague ("there's a bug", "/diagnose"), interview them one question at a time until you have enough to attempt a reproduction; if you still cannot reproduce, say so explicitly. Then drive the work through five phases — build a deterministic feedback loop, reproduce, hypothesise, probe, write a spec — and hand off to TDD for the regression test. Trigger when the user reports something broken, slow, wrong, or regressed: "X is failing", "this throws", "something regressed", "diagnose this", "debug this", "investigate why...".
---

# Diagnose

Symptom in, fix-with-regression-test out. An interview if the user opens vague, then five phases, two cardinal rules.

## Skip diagnose for

One-line obvious fixes (typo, missing import, off-by-one in a test you just wrote). "Bugs" that are actually missing functionality — that's a feature, use `interview-to-spec`. Flaky tests caused by infrastructure (CI, network) rather than code under test.

## Two rules that keep diagnosis honest

1. **No loop, no Phase 2+.** If you cannot reproduce the bug deterministically, you cannot hypothesise — you'll just guess.
2. **One variable at a time during probing.** Changing two things at once tells you nothing about either.

If either slips, back up.

## Phase 0 — Understand the bug

Before building a loop, you need to know what you're trying to reproduce. **If the user opened with detail covering the points below, skip this phase.** If they opened vague ("there's a bug", "X is broken", or just `/diagnose`), interview them.

Ask **one question at a time**. Stop the moment you have enough to attempt Phase 1 — do not gather more than you need.

The minimum set you're trying to fill:

- **Expected vs. actual.** What should have happened? What actually happened?
- **Trigger.** What were they doing when it happened? Can they make it happen again on demand, or is it intermittent?
- **Recency.** Did this used to work? When did it start failing? What changed recently (deploy, dependency, data, config)?
- **Environment.** Where? (prod / staging / local; specific browser, OS, account, dataset.)
- **Evidence.** Any error message, stack trace, log line, screenshot, or HAR they can paste?

If the answer to a question is in the codebase rather than in the user's head, **read the code instead of asking**.

When the answers converge, propose a short slug for the bug (e.g. `token-expiry-not-rejected`). This is the filename for the spec written in Phase 5. Then move to Phase 1.

If after the interview the user still cannot give you enough to reproduce, that is itself a Phase 1 outcome — go to Phase 1 and follow **When you genuinely cannot build a loop**.

## Phase 1 — Build the feedback loop

**This is the skill.** Everything downstream is mechanical once you have a fast, deterministic, agent-runnable pass/fail signal for the bug. Without one, no amount of staring at code finds the cause.

Spend disproportionate effort here. Be aggressive. Refuse to give up.

### Ways to build one — try in roughly this order

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser** (Playwright / Puppeteer) — drives the UI, asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real request/payload/event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** A minimal subset of the system that exercises the bug code path with one function call.
7. **Property / fuzz loop.** For "sometimes wrong output", run 1000 random inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so `git bisect run` works.
9. **Differential loop.** Run the same input through old vs new (or two configs) and diff outputs.
10. **HITL bash script.** Last resort. If a human must click, drive them with a structured loop and capture output back to you.

### Iterate on the loop itself

Treat the loop as a product. Once you have *a* loop, ask:

- **Faster?** Cache setup, skip unrelated init, narrow scope.
- **Sharper signal?** Assert on the specific symptom, not "didn't crash".
- **More deterministic?** Pin time, seed RNG, isolate filesystem, freeze network.

A 30-second flaky loop is barely a loop. A 2-second deterministic loop is a debugging superpower.

### Non-deterministic bugs

Goal isn't a clean repro — it's a *higher reproduction rate*. Loop the trigger 100×, parallelise, narrow timing windows, inject sleeps. A 50%-flake bug is debuggable; 1% is not — keep raising the rate until it is.

### When you genuinely cannot build a loop

Stop and say so explicitly. List what you tried. Ask the user for one of:

- Access to an environment that reproduces it.
- A captured artifact (HAR file, log dump, core dump, screen recording with timestamps).
- Permission to add temporary production instrumentation.

Do **not** proceed to Phase 3 without a loop.

## Phase 2 — Reproduce

Run the loop. Watch the bug appear. Confirm:

- The loop produces the failure mode the **user** described — not a different failure that happens to be nearby. Wrong bug = wrong fix.
- The failure is reproducible across multiple runs (or, for non-deterministic bugs, at a high enough rate to debug against).
- You captured the exact symptom (error message, wrong output, slow timing) so later phases can verify the fix addresses it.

Do not proceed until you reproduce the bug.

## Phase 3 — Hypothesise

Generate **3–5 ranked hypotheses** before testing any. Single-hypothesis generation anchors on the first plausible idea.

Each hypothesis must be **falsifiable** — state the prediction it makes:

> If `<X>` is the cause, then changing `<Y>` will make the bug disappear / changing `<Z>` will make it worse.

If you cannot state the prediction, the hypothesis is a vibe — discard or sharpen it.

**Show the ranked list to the user before probing.** They often have domain knowledge that re-ranks instantly ("we just deployed a change to #3"), or know hypotheses they've already ruled out. Cheap checkpoint, big time saver. Do not block — proceed with your ranking if the user is AFK.

## Phase 4 — Probe

Each probe maps to a specific prediction from Phase 3. **Change one variable at a time.**

Tool order:

1. **Debugger / REPL inspection** if the env supports it. One breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`. Cleanup at the end becomes a single grep. Untagged logs survive; tagged logs die.

**Perf branch.** For performance regressions, logs lie. Establish a baseline measurement (timing harness, `performance.now()`, profiler, query plan), then bisect. Measure first.

By the end of Phase 4 you have **the root cause** — the hypothesis from Phase 3 that survived.

## Phase 5 — Write the spec

Synthesise everything into `spec/<slug>.md`. The spec is the input contract for `tdd`.

Use these sections:

```markdown
# <slug>

## Symptom
What the user observed (error message, wrong output, slow timing).

## Reproduction
The deterministic trigger from Phase 1. A test name, a curl, a script — whatever the loop is.

## Root cause
What is actually wrong. The hypothesis from Phase 3 that survived Phase 4.

## Fix
What will change to correct the cause. One paragraph.

## Acceptance criteria
- A new regression test (named `<test_name>`) fails without the fix and passes with it.
- Behaviour Y still works.
- (Add more as needed — keep them observable, not internal.)

## Related risks
Other places in the code that share the pattern or module and may carry the same bug. Listed for follow-up, not for this fix.
```

Then hand off to `tdd`. The spec's **Reproduction** + **Acceptance criteria** become the test queue.

If Phase 4 surfaces an architectural issue (no good test seam, tangled callers, hidden coupling), capture it under **Related risks** — but do **not** rewrite architecture during diagnose. Make that recommendation after the fix lands.

## Cleanup before declaring done

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop).
- [ ] Regression test passes.
- [ ] All `[DEBUG-...]` instrumentation removed (`grep` the prefix).
- [ ] Throwaway prototypes deleted (or moved to a clearly marked location).
- [ ] The winning hypothesis is captured in the spec — so the next debugger learns from it.

## Where this skill ends

You hand off to `tdd` with `spec/<slug>.md` written. `tdd` runs red-green-refactor against the acceptance criteria. After `tdd` is green, the work joins the normal review / PR flow.
