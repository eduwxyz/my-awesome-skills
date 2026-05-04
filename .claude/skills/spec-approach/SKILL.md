---
name: spec-approach
description: Add a refined `## Approach` section to an existing feature spec.md before TDD executes it. Reads the spec, explores the codebase to ground the approach in real modules and patterns, proposes 2–3 alternatives when they exist, validates with the user, then appends `## Approach` to the same spec file. Trigger after `interview-to-spec` for non-trivial features when the user says "plan the approach", "spec the implementation", "design the approach", "how are we building this", or before invoking `tdd` on a feature whose HOW is unclear.
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash ./hooks/spec-integrity.sh"
---

# Spec Approach

Take an existing feature spec and add the `## Approach` — the HOW that `tdd` needs to execute. Same file, append only.

## Skip spec-approach for

- **Bug specs** (output of `diagnose` — already contain `Root cause` and `Fix`).
- **Trivial changes** — single file, obvious extension of an existing pattern.
- **Specs that already have `## Approach`** — unless the user explicitly asks to revise.

If invoked in a skip case, recognise it and tell the user "this looks trivial / already approached — go straight to `tdd`". Do not write anything.

## Before you start

**Identify the spec.** A path or slug for an existing `spec/<slug>.md` must be given. If neither was provided, ask the user which spec — do not guess. Never operate without an explicit target.

**Validate it.** Read the file. It must contain `Goal`, `Behaviors`, and `Acceptance criteria`. If any are missing, abort and tell the user to run `interview-to-spec` first. Never try to fill in WHAT.

## The work

1. **Read the spec.** Internalise Goal, Behaviors, AC, OOS, Edge cases.
2. **Explore the codebase.** Find relevant modules, patterns, existing ADRs, similar features. The approach must be grounded in what is actually there — not invented.
3. **Propose.** State a recommended approach. If multiple paths are viable, show 2–3 with tradeoffs and recommend one.
4. **Validate with the user.** Ask one question at a time, only when judgment is required (which alternative? what's the priority?). Do not ask what the codebase can answer — read the codebase.
5. **Append.** Add `## Approach` to the same spec file.

## How to append (safety rules)

- Use **`Edit`**, not `Write`. Anchor on the last existing line or section of the spec; the new content is the anchor + `\n\n## Approach\n...`.
- **Never** create a new file.
- **Never** modify the WHAT sections above (Goal, Behaviors, AC, OOS, Edge cases). Touch only the bottom of the file.
- If the spec ends with a trailing newline, preserve it.

## The `## Approach` section

```markdown
## Approach
- **Strategy.** One paragraph describing how the work will be done end-to-end.
- **Modules / files.** Concrete paths to create or modify.
- **Key decisions.** The alternative considered and why this one. One bullet per decision.
- **Schema / API changes.** If any. Otherwise omit this bullet.
- **Risks.** Anything that might surprise us during execution. If none, omit this bullet.
```

Keep each bullet tight. The reader is `tdd` — it needs enough to execute, not a design doc.

## When `## Approach` already exists

Do **not** overwrite silently. Read the existing approach, then ask the user: "There's already an approach here. Want me to revise it, or is it still good?" Only edit if they confirm. When revising, replace the existing `## Approach` block via `Edit` — do not append a second one.

## Where this skill ends

The spec is now self-sufficient. `tdd` consumes it directly — Behaviors + Acceptance criteria become the test queue; Approach guides the implementation.
