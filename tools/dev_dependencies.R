# Dev / tooling dependencies
#
# This file is declared SOLELY so renv's implicit dependency scanner records
# these tools in renv.lock. It is never sourced or run at app time — it exists
# so that dev-only tools stay reproducible for contributors and CI, while
# `renv::status()` stays clean (a recorded-but-unused package otherwise reports
# as drift). See .claude/rules/renv.md (Rules 1 & 3).

library(lintr)   # static analysis / linting; config in .lintr at the repo root
