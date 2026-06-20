#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Stop hook — renv lockfile drift reminder (backlog #6 B)
#
# When Claude's turn ends, ask renv whether the lockfile is still in sync with
# the library. Authoritative (uses renv::status(), not text-guessing about
# library() calls) and cheap (only consults renv when an R source has changed
# more recently than renv.lock).
#
# INFORM mode — surfaces a user-facing systemMessage and exits 0; never blocks.
# To ENFORCE instead (force Claude to resolve drift before finishing), replace
# the final jq line with:
#     jq -n --arg m "$msg" '{decision:"block",reason:$m}'
# -----------------------------------------------------------------------------
set -uo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
lock="$root/renv.lock"
[ -f "$lock" ] || exit 0   # not an renv project — nothing to check

# Cheap guard: only consult renv if some tracked .R file is newer than the
# lockfile. After a snapshot, renv.lock is the newest file, so quiet turns skip
# the (slower) Rscript call entirely.
newer="$(find "$root" -name '*.R' -newer "$lock" \
           -not -path '*/renv/*' \
           -not -path '*/.git/*' \
           -not -path '*/.Rproj.user/*' 2>/dev/null | head -n 1)"
[ -z "$newer" ] && exit 0   # nothing R-ish changed since last snapshot

# Consult renv itself. .Rprofile (sourced by Rscript) activates renv.
status="$(cd "$root" && Rscript -e 'suppressMessages(renv::status())' 2>&1 || true)"

# renv prints this exact phrase when the project is consistent.
if printf '%s' "$status" | grep -q "No issues found"; then
  exit 0
fi

msg="renv may be out of sync — an R source changed since the last snapshot and renv::status() did not report a clean state. If a package was added, removed, or updated, run renv::snapshot() and commit renv.lock in the SAME commit (renv rule 5). renv::status() reported:
${status}"

jq -n --arg m "$msg" '{systemMessage:$m}'
exit 0
