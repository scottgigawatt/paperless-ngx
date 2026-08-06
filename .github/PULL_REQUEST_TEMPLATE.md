<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  PULL_REQUEST_TEMPLATE.md: Form PR-666 for changing the HADES archive.
  -->

# Form PR-666: Request to Disturb the Archives 🗃️🔥

The Eternal Change Advisory Board appreciates your submission. The Board is one
person, but adding "Eternal" doubled its stationery budget.

## What mortal machinery changed? ⚙️

-

## Why must the slumbering configuration be disturbed? 🧟

-

## Trial by Paperwork 🧪

- [ ] `make help`
- [ ] `make validate`
- [ ] `pre-commit run --all-files`
- [ ] `git diff --check`
- [ ] `make config` if a private non-production `.env` was available
- [ ] Live migration/health checks are clearly separated from local validation

## Anti-Demon Upgrade Wards 🕯️

- [ ] The current and target application/database versions are recorded
- [ ] Required intermediate versions were not skipped
- [ ] Backup and restore boundaries are documented
- [ ] Upstream migration notes were reviewed for major updates
- [ ] `PAPERLESS_SECRET_KEY` remains stable unless rotation is intentional

## Cerberus Security Inspection 🐕🔐

- [ ] No `.env`, signing key, password, API token, document, database, or private log
- [ ] Example values remain obviously non-production
- [ ] Runtime `config/` directories contain only their checked-in `.gitignore` files

## Chief Infernal Archivist's Notes 🖋️

-

By submitting this form, I acknowledge that "the database looked fine from
across the room" is not a rollback plan.
