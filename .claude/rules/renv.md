# renv — Package Environment Management

These rules apply whenever packages are added, removed, or updated in any R or Shiny project.

## Rule 1 — Always snapshot after changing packages

Any time you install, remove, or update a package, run `renv::snapshot()` immediately after to record the change in the lockfile. Never leave the lockfile out of sync with the installed library.

```r
# Install a package, then immediately snapshot
install.packages("DT")
renv::snapshot()

# Remove a package, then immediately snapshot
renv::remove("DT")
renv::snapshot()

# Update packages, then immediately snapshot
renv::update("DT")
renv::snapshot()
```

## Rule 2 — Check status before and after

Before making any package changes, check for existing drift. After snapshotting, confirm the lockfile is clean.

```r
# Before: check current state
renv::status()

# After installing / updating packages
renv::snapshot()
renv::status()   # should report "No issues found"
```

If `renv::status()` reports issues at the start of a session, resolve them before adding more packages. Options:

- `renv::snapshot()` — to record what's installed (you made changes locally)
- `renv::restore()` — to revert to the lockfile state (someone else updated the lockfile)

## Rule 3 — Use the right snapshot type

| App Type | Snapshot Type | Command |
|----------|--------------|---------|
| Raw Shiny app | `"implicit"` (default) — scans files for `library()` calls | `renv::snapshot()` |
| golem / leprechaun (package-based) | `"explicit"` — reads `DESCRIPTION` file only | `renv::snapshot(type = "explicit")` |

For package-based apps, list all runtime dependencies in `DESCRIPTION` under `Imports:` before snapshotting. This keeps the lockfile clean and prevents stale dev packages from sneaking in.

## Rule 4 — What to commit vs. ignore

**Always commit:**
- `renv.lock` — the reproducible environment record
- `renv/.gitignore` — renv writes this automatically
- `.Rprofile` — activates renv when the project opens

**Never commit:**
- `renv/library/` — built packages (platform-specific, large)
- `renv/staging/` — temporary install staging area
- `renv/sandbox/` — renv internal sandbox

The standard `renv/.gitignore` handles most of this automatically after `renv::init()`.

## Rule 5 — Commit the lockfile with the code change

When a PR or commit adds a new package dependency, the `renv.lock` update must be in the same commit as the code that requires the package. Lockfile changes committed separately are easy to miss during review and break `renv::restore()` for others mid-commit.

```
# Good commit
feat: add DT table to patient listing module

R/mod_patient_listing.R   (uses DT)
renv.lock                  (DT recorded)

# Bad commit — lockfile is a follow-up
feat: add DT table to patient listing module
R/mod_patient_listing.R

(later) chore: update renv.lock   <- breaks reproducibility between commits
```

## Rule 6 — Restore before running in a new environment

Any time a project is cloned, pulled after a lockfile change, or run in CI, restore before anything else:

```r
# First thing in a new environment or after a lockfile update
renv::restore()
```

In CI pipelines (GitHub Actions / GitLab CI), place `renv::restore()` as the first R step. Cache the renv library by lockfile hash to avoid reinstalling on every run.

## Quick Reference

| Task | Command |
|------|---------|
| Check for drift | `renv::status()` |
| Record installed packages to lockfile | `renv::snapshot()` |
| Install lockfile packages to library | `renv::restore()` |
| Update a package and record it | `renv::update("pkg"); renv::snapshot()` |
| Remove a package and record it | `renv::remove("pkg"); renv::snapshot()` |
| See what is in the lockfile | `renv::lockfile_read()` |
| Initialize renv in a new project | `renv::init()` |
