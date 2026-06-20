#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# PostToolUse hook — record edited R files for the batched Stop-time lint
# (backlog #6 A, part 1 of 2).
#
# Cheap (no R): appends each edited .R path to a per-turn queue that lint-r.sh
# drains at Stop. This captures exactly the files touched THIS turn, so the lint
# pass never reports on unrelated pre-existing uncommitted files.
# -----------------------------------------------------------------------------
set -uo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -z "$file_path" ] && exit 0

# R source files only; skip the renv library and git internals.
case "$file_path" in
  *.R|*.r) ;;
  *) exit 0 ;;
esac
case "$file_path" in
  */renv/*|*/.git/*) exit 0 ;;
esac

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
queue="$root/.claude/.lint-queue"

touch "$queue" 2>/dev/null || exit 0
# Dedup: only append if not already queued this turn.
grep -qxF "$file_path" "$queue" 2>/dev/null || printf '%s\n' "$file_path" >> "$queue"
exit 0
