#!/usr/bin/env bash
# tdd Stop hook with two responsibilities:
#
# (1) Tests must be green. Reads the project's test command from
#     .agents/tdd/test-command.txt (set up by the tdd skill on its
#     first run); if the command exits non-zero, blocks the Stop
#     with the test output as the reason.
#
# (2) The `simplify` skill must be invoked once per session after
#     tests turn green. Tracked via a per-session marker file
#     (.agents/tdd/simplify-asked-<session_id>). On the first Stop
#     with green tests in a session, writes the marker and blocks
#     with a prompt to invoke `simplify`. On subsequent Stops, the
#     marker is present and this gate passes.
#
# Missing test command file or session id → that respective gate is
# skipped (assume tdd setup hasn't run yet).

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')

# === 1. Tests must be green ===

cmd_file=".agents/tdd/test-command.txt"
if [[ -f "$cmd_file" ]]; then
  cmd=$(tr -d '\n' < "$cmd_file")
  if [[ -n "$cmd" ]]; then
    output=$(bash -c "$cmd" 2>&1)
    if [[ $? -ne 0 ]]; then
      echo "Tests red. Cannot end session — fix them first." >&2
      echo "" >&2
      echo "Command: $cmd" >&2
      echo "" >&2
      echo "$output" >&2
      exit 2
    fi
  fi
fi

# === 2. Simplify must have been invoked once this session ===

if [[ -n "$session_id" ]]; then
  marker=".agents/tdd/simplify-asked-$session_id"
  if [[ ! -f "$marker" ]]; then
    mkdir -p .agents/tdd
    touch "$marker"
    echo "Tests are green. Before stopping, invoke the \`simplify\` skill on the" >&2
    echo "recent changes to review them for reuse, quality, and efficiency." >&2
    echo "Apply any improvements found (re-running tests if simplify edits code)," >&2
    echo "then attempt to stop again." >&2
    exit 2
  fi
fi

exit 0
