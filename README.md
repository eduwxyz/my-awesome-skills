# my-awesome-skills

A collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills.

## Skills

| Path | Purpose |
|---|---|
| [`.claude/skills/tdd/`](.claude/skills/tdd/) | Test-driven development with red-green-refactor. Enforces vertical slicing, names common test smells, includes guidance for legacy code. |
| [`.claude/skills/interview-to-spec/`](.claude/skills/interview-to-spec/) | Interview the user one branch at a time to draft a `spec/<slug>.md` for the upcoming task — the input step of spec-driven development. |

## How to use

Claude Code reads skills from two locations:

- `~/.claude/skills/<name>/` — available to every project on your machine.
- `<repo>/.claude/skills/<name>/` — committed alongside a specific repo and shared with anyone who clones it.

Pick whichever fits the use case.

### Per-user install

```bash
git clone https://github.com/eduwxyz/my-awesome-skills.git
mkdir -p ~/.claude/skills
cp -r my-awesome-skills/.claude/skills/* ~/.claude/skills/
```

Restart Claude Code (or open a new conversation) to pick the skill up.

### Per-repo install

Drop the skill directory into the target repo, commit, and let teammates get it on their next pull.

```bash
mkdir -p <target-repo>/.claude/skills
cp -r my-awesome-skills/.claude/skills/tdd <target-repo>/.claude/skills/
cd <target-repo>
git add .claude/skills/tdd
git commit -m "chore: add TDD skill"
```
