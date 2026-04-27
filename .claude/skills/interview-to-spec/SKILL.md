---
name: interview-to-spec
description: Conduct a focused interview to draft a spec.md for an upcoming task (the input step of SDD — spec-driven development). Walks through goal, behaviors, acceptance criteria, edge cases, and out-of-scope one branch at a time, then writes the spec to disk. Trigger when the user wants to draft a spec before implementation, mentions "draft the spec", "let's spec this out", "what should we build", or starts an SDD workflow.
---

Interview the user to draft a spec for the task at hand. Cover goal, behaviors, acceptance criteria, edge cases, and out-of-scope — one branch at a time, resolving each before moving on. For every question, offer your own recommended answer.

Ask one question at a time.

If a question can be answered by exploring the codebase, explore it instead.

When the interview converges, write the spec to `spec/<short-task-slug>.md` (create the directory if missing). Use these sections:

- **Goal** — what this task delivers, in user-facing language.
- **Behaviors** — what the system will do, observable from the outside.
- **Acceptance criteria** — how we know the work is done.
- **Out of scope** — what's deliberately not included.
- **Edge cases** — situations that need special handling.

Keep the spec focused on the *what* and *why*. Implementation details belong in a later step.
