#!/usr/bin/env bash
# Block Stop while verify's last verdict is "Not ready".
# Forces the iteration: gaps → tdd → re-verify → clean.
#
# Reads .agents/verify/last-verdict.txt (written by the verify skill at
# the end of every run). Single line, either "Ready" or "Not ready".
#
# Triggered as a Stop hook from the verify skill frontmatter.

verdict_file=".agents/verify/last-verdict.txt"

# No verdict written yet — verify hasn't run. Don't block.
if [[ ! -f "$verdict_file" ]]; then
  exit 0
fi

verdict=$(tr -d '\n' < "$verdict_file")

# Ready — allow stop.
if [[ "$verdict" == "Ready" ]]; then
  exit 0
fi

# Not ready (or anything else) — block.
echo "Verify reported gaps. Hand off to tdd, fix them, re-run verify before ending the turn." >&2
exit 2
