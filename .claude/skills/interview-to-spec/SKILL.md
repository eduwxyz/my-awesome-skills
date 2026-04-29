---
name: interview-to-spec
description: Conduct a focused interview to draft a spec.md for an upcoming task (the input step of SDD — spec-driven development). Walks through goal, behaviors, acceptance criteria, edge cases, and out-of-scope one branch at a time, then writes the spec to disk. If during the interview the scope turns out to be multiple independent features, pauses and asks the user to pick one — the chosen one becomes the spec, the rest stay outside the repo. Trigger when the user wants to draft a spec before implementation, mentions "draft the spec", "let's spec this out", "what should we build", or starts an SDD workflow.
---

Interview the user to draft a spec for the task at hand. Cover goal, behaviors, acceptance criteria, edge cases, and out-of-scope — one branch at a time, resolving each before moving on. For every question, offer your own recommended answer.

Ask one question at a time.

If a question can be answered by exploring the codebase, explore it instead.

## One spec = one feature

If during the interview you sense the scope is actually multiple independent features (separate goals, different code paths, would ship as separate PRs), **pause and propose a split**. Show 2–5 one-line options and ask the user to pick which one to spec first.

Continue the interview for *only* that one. The others stay outside the repo — the user manages them wherever they keep their backlog (issue tracker, notes, their head). Do **not** mention them in the spec. Do **not** add a "follow-up" or "future work" section. Do **not** create a roadmap file. The spec describes only the work being executed now.

When the user wants to do another one later, they invoke `interview-to-spec` again with that idea as the input.

## Writing the spec

When the interview converges, write the spec to `spec/<short-task-slug>.md` (create the directory if missing). Use these sections:

- **Goal** — what this task delivers, in user-facing language.
- **Behaviors** — what the system will do, observable from the outside.
- **Acceptance criteria** — how we know the work is done.
- **Out of scope** — what's deliberately not included.
- **Edge cases** — situations that need special handling.

Keep the spec focused on the *what* and *why*. Implementation details belong in a later step.
