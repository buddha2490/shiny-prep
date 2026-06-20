#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# PostToolUse hook — test reminder (backlog #6 C)
#
# Fires after Claude edits a Shiny module / utility / function R file and feeds
# a reminder back into Claude's context: where the conventional testthat file
# lives (or that it's missing), and that the FULL suite should be re-run.
#
# INFORM mode only — exits 0 and returns additionalContext; never blocks.
# Reads the PostToolUse JSON event on stdin; emits a JSON response on stdout.
# -----------------------------------------------------------------------------
set -uo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -z "$file_path" ] && exit 0

base="$(basename "$file_path")"

# Only react to module / utility / function source files under an R/ directory.
case "$file_path" in
  */R/mod_*.R|*/R/utils_*.R|*/R/fct_*.R) ;;
  *) exit 0 ;;
esac

# Conventional testthat path for this repo: underscores in the source name
# become dashes, prefixed with "test-"  (utils_error.R -> test-utils-error.R).
app_root="$(dirname "$(dirname "$file_path")")"   # .../R/<file>  ->  app root
stem="${base%.R}"
dash_stem="$(printf '%s' "$stem" | tr '_' '-')"
test_dash="$app_root/tests/testthat/test-$dash_stem.R"
test_us="$app_root/tests/testthat/test-$stem.R"

if [ -f "$test_dash" ]; then
  status="exists ($test_dash)"
elif [ -f "$test_us" ]; then
  status="exists ($test_us)"
else
  status="not found at the conventional path (expected $test_dash) — it may live under a behaviour-named test file, or it may be missing"
fi

msg="You edited ${base}. Its testthat file ${status}. Per testing rule 4, update or add the tests for this change and run the FULL suite (testthat::test_dir, not just this file) in the renv-activated process (testing rule 7)."

jq -n --arg m "$msg" \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$m}}'
exit 0
