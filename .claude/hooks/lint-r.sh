#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Stop hook — batched lintr pass (backlog #6 A, part 2 of 2).
#
# Drains the per-turn queue written by lint-record.sh and lints exactly those
# R files in ONE R process (one startup per turn, not per edit). Uses the repo
# .lintr config (auto-discovered by lint()).
#
# INFORM mode — surfaces a user-facing systemMessage and exits 0; never blocks.
# To ENFORCE (make Claude resolve findings before finishing), replace the final
# jq line with:  jq -n --arg m "$msg" '{decision:"block",reason:$m}'
# -----------------------------------------------------------------------------
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
queue="$root/.claude/.lint-queue"
[ -s "$queue" ] || { rm -f "$queue" 2>/dev/null; exit 0; }   # nothing recorded

# Read unique, still-existing paths (bash 3.2 safe — no mapfile).
files=()
while IFS= read -r line; do
  [ -n "$line" ] && [ -f "$line" ] && files+=("$line")
done < <(sort -u "$queue")
rm -f "$queue" 2>/dev/null   # clear regardless of outcome — don't re-lint next turn
[ ${#files[@]} -eq 0 ] && exit 0

# Lint all queued files in a single R process. stderr (renv banner) is dropped;
# only the formatted findings reach stdout.
out="$(cd "$root" && Rscript -e '
  args <- commandArgs(trailingOnly = TRUE)
  suppressMessages(library(lintr))
  res <- character(0)
  for (f in args) {
    ls <- tryCatch(lint(f), error = function(e) NULL)
    if (is.null(ls) || length(ls) == 0) next
    for (x in ls) res <- c(res, sprintf("%s:%s:%s [%s] %s",
      x$filename, x$line_number, x$column_number, x$linter, x$message))
  }
  if (length(res)) cat(paste(res, collapse = "\n"))
' "${files[@]}" 2>/dev/null || true)"

# Keep only genuine "path:line:col [linter] msg" lines — drops the renv startup
# banner that this project's .Rprofile prints to stdout on every Rscript run.
out="$(printf '%s\n' "$out" | grep -E ':[0-9]+:[0-9]+ \[' || true)"

[ -z "$out" ] && exit 0

msg="lintr findings on the R file(s) edited this turn (per the repo .lintr config). Fix issues consistent with r-style.md, or note why a finding is intentional:
$out"

jq -n --arg m "$msg" '{systemMessage:$m}'
exit 0
