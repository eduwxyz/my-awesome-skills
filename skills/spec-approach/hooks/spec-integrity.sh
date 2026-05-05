#!/usr/bin/env bash
# Block Write to an existing spec/<slug>.md file.
# Forces the model to use Edit (with an anchor), preserving the WHAT
# sections written by interview-to-spec or diagnose.
#
# Triggered as a PreToolUse hook with matcher "Write" inside the
# spec-approach skill frontmatter.

set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

# Not a spec file — let it through.
if [[ ! "$file_path" =~ (^|/)spec/[^/]+\.md$ ]]; then
  exit 0
fi

# Spec file but does not exist yet — creating a new spec is fine.
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Existing spec + Write attempt — block.
echo "Spec exists at $file_path. Use Edit (with an anchor on existing content) to append \`## Approach\`; never Write to an existing spec." >&2
exit 2
