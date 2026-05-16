---
name: feature
description: Kick off the full feature workflow — interview-to-spec, optional spec-approach, tdd, verify, then review — when starting a new feature from scratch. Thin orchestrator: confirms intent in one sentence, then hands off to the first stage and lets each downstream skill activate on its own. Trigger when the user says "new feature", "let's build a feature", "start a feature", "build feature X end-to-end", "kick off a feature", "/feature".
---

# Feature

The orchestrated path for building a new feature, from idea to PR-ready. This skill is a thin dispatcher — it confirms intent and hands off. Each downstream skill activates on its own.

## When to use this

You want the full SDD pipeline in order without having to remember each step.

## When NOT to use this

- **Bug fix.** Use `diagnose` instead.
- **Trivial change** that doesn't need a spec (one-line config, doc tweak). Edit directly.
- **Already partway through a workflow.** Resume at the relevant stage by invoking the matching skill (`interview-to-spec`, `spec-approach`, `tdd`, `verify`).

## The pipeline

You will pass through these stages in order:

1. **`interview-to-spec`** — hand off. The skill conducts the interview and writes `spec/<slug>.md` (Goal, Behaviors, Acceptance criteria, Out of scope, Edge cases).

2. **`spec-approach`** *(optional)* — when the spec is written, judge whether the HOW is non-trivial:
   - Multiple modules touched?
   - Multiple viable approaches?
   - Architectural decision required?
   - Schema or API changes?

   If yes, invoke `spec-approach` to append `## Approach` to the spec. If no, skip and move on.

3. **`tdd`** — hand off. Red-green-refactor against the spec's Behaviors + Acceptance criteria. The skill itself ensures `.agents/tdd/test-command.txt` is configured on first run, and its Stop hook will gate on green tests + a pass through `simplify`.

4. **`verify`** — hand off. Maps every AC to a green test. If gaps exist, the skill auto-iterates with `tdd` until clean. Will not return until the verdict is `Ready`.

5. **`review`** *(built-in)* — when verify reports `Ready`, hand off for code review. Then open the PR.

## How handoff works

This skill ends as soon as you invoke `interview-to-spec`. It does not stay active across the pipeline. Each downstream skill activates from its own trigger phrasing as the conversation progresses.

If you stop the session midway and resume later, invoke the next stage's skill directly — do not re-invoke `feature`.

## What to do first

Confirm the user's intent in **one sentence** ("Kicking off the feature workflow for `<short-description>`."), then immediately invoke `interview-to-spec`. Do not attempt the interview yourself — that is `interview-to-spec`'s job.
