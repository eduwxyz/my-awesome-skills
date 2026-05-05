# my-awesome-skills

A spec-driven development pipeline for [Claude Code](https://docs.claude.com/en/docs/claude-code). Refine the spec before you code, let TDD enforce it, verify nothing slipped, then review.

## Why this approach

LLMs produce code well but produce *the right* code only when constrained. Every gap left in a prompt becomes a place for the model to fill in plausible-but-wrong assumptions. These skills implement an SDD pipeline that adds constraints — *amarras* — at every stage, so by the time human review starts, "is this what we wanted?" is already answered mechanically.

The pipeline compounds:

1. **`interview-to-spec`** captures the **WHAT** — Goal, Behaviors, Acceptance criteria, edge cases. Every AC is an amarra: the implementation must satisfy it.
2. **`spec-approach`** adds the **HOW** — strategy, modules touched, key decisions, schema changes, risks. Now the spec describes both intent and the implementation path.
3. **`tdd`** turns each behavior into a failing test, then writes the minimum code to pass. Each test is an executable amarra — the code is constrained not just by the spec text, but by the suite that proves it.
4. **`verify`** maps every spec AC to a green test. If a single AC has no test, the verdict is `Not ready` and the workflow auto-loops back to TDD until clean. Mechanical guarantee that nothing slipped.
5. **`review`** (built-in) focuses purely on code quality. The "is this what we wanted?" question is already answered.

By review time, the work has been pinned down by **the spec contract + the tests + the verify gate**. Reviewers (you, or the built-in `review` skill) only have to think about quality and style.

For bugs, `diagnose` produces a bug-shaped spec (Symptom, Reproduction, Root cause, Fix, AC) and the rest of the pipeline is identical. One contract, two entrypoints.

## The two workflows

```
FEATURE                                    BUG
───────                                    ───
interview-to-spec                          diagnose
       ↓                                       ↓
[spec-approach]   (if non-trivial)             ↓
       ↓                                       ↓
       └────────────────┐         ┌────────────┘
                        ↓         ↓
                       spec/<slug>.md      ← single contract
                            ↓
                          tdd
                            ↓
                        verify             ← gate
                            ↓
                       review (built-in) → PR
```

Both branches converge on the same `spec/<slug>.md`. `tdd` and `verify` don't know — or care — which branch produced it.

## Skills

| Skill | Purpose | When to use | When to skip | Output |
|---|---|---|---|---|
| **`feature`** | Orchestrator: kicks off the full feature pipeline | Starting a feature from scratch | Bug fix; trivial change; mid-pipeline | Hands off to `interview-to-spec` |
| **`interview-to-spec`** | Interview to draft `spec/<slug>.md` (Goal, Behaviors, AC, edge cases, OOS) | Beginning a feature; need to capture WHAT | Already have a complete spec | `spec/<slug>.md` |
| **`spec-approach`** | Append `## Approach` section (strategy, modules, decisions, schema, risks) | Non-trivial feature where HOW is unclear; multi-module change; architectural decision | Bug spec; trivial single-file change; spec already has Approach | Same spec, with appended section |
| **`diagnose`** | Bug entrypoint: interview, build deterministic repro, hypothesise, probe, write bug spec | Something is broken/wrong/regressed | Obvious one-line fix; missing functionality (use `interview-to-spec`) | `spec/<slug>.md` (bug-shaped) |
| **`tdd`** | Red-green-refactor loop driven by the spec | Implementing the spec; fixing a regression | Spikes; visual-only edits; throwaway scripts | Code + tests, all green |
| **`verify`** | Map every AC to a green test, surface gaps, auto-iterate until clean | After `tdd` green, before opening PR | Spike work; spec without AC | Verify report + verdict |

Each skill carries its own triggers in the `description` frontmatter — Claude Code activates them automatically based on natural-language phrasing. You can also invoke explicitly (e.g. "let's spec this out", "diagnose this bug", "verify the spec").

## Hooks

Hooks live in each skill's frontmatter and activate only when the skill is active. They turn the skill's textual rules into hard guarantees.

| Skill | Hook | Enforces |
|---|---|---|
| `spec-approach` | `PreToolUse` on `Write` | Blocks `Write` to an existing `spec/*.md` — forces `Edit` so the WHAT sections written upstream are preserved byte-for-byte |
| `tdd` | `Stop` | (1) Tests must be green (reads command from `.claude/tdd/test-command.txt`). (2) `simplify` must be invoked once per session before stopping |
| `verify` | `Stop` | Blocks the turn while `.claude/verify/last-verdict.txt` says `Not ready` — forces iteration through `tdd` until the spec is satisfied |

Hooks fire mechanically — they're shell scripts on the harness side, not LLM judgments — so a skill's rules cannot be ignored even if the model decides to skip a step.

## Installation

This repo is a [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces). The skills ship together as a single plugin, `sdd-pipeline`.

```
/plugin marketplace add eduwxyz/my-awesome-skills
/plugin install sdd-pipeline@my-awesome-skills
```

**Restart Claude Code** after installing so the hooks load.

### Updating

```
/plugin marketplace update my-awesome-skills
```

Each commit to this repo is treated as a new version (the `version` field is omitted in `marketplace.json`, so the git SHA distinguishes releases).

### Useful subsets

All six skills install together. You don't have to use all of them — Claude Code only activates a skill when its trigger phrasing matches. Common cores:

- **Features only:** `interview-to-spec` + `tdd` + `verify`.
- **Bugs only:** `diagnose` + `tdd` + `verify`.
- **Both with orchestrator:** add `feature` and `spec-approach` on top.

## First-run setup in a project

The first time you invoke `tdd` in a new project, it will create `.claude/tdd/test-command.txt` with the project's test command (one line, e.g. `npm test` or `uv run pytest`). The Stop hook reads this file. Edit it directly to change the command.

`verify` writes `.claude/verify/last-verdict.txt` after each run. Both directories live inside the *target project*, not in `~/.claude/`.

## Skipping the pipeline

The skills include explicit "skip" sections — for typos, doc tweaks, spikes, generated files, and so on. The pipeline pays off when the work has real surface area. Don't drag a one-line PR through `interview-to-spec → spec-approach → tdd → verify` just because it exists.
