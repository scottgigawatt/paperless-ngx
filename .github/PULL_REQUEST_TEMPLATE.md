# Filing Cabinet Change Request 🗃️🔥

## What changed?

-

## Why?

-

## Validation

- [ ] `make help`
- [ ] `make validate`
- [ ] `pre-commit run --all-files`
- [ ] `git diff --check`
- [ ] `make config` if a private non-production `.env` was available
- [ ] Live migration/health checks are clearly separated from local validation

## Upgrade safety

- [ ] The current and target application/database versions are recorded
- [ ] Required intermediate versions were not skipped
- [ ] Backup and restore boundaries are documented
- [ ] Upstream migration notes were reviewed for major updates
- [ ] `PAPERLESS_SECRET_KEY` remains stable unless rotation is intentional

## Secrets and private data

- [ ] No `.env`, signing key, password, API token, document, database, or private log
- [ ] Example values remain obviously non-production
- [ ] Runtime `config/` directories contain only their checked-in `.gitignore` files

## Archivist's notes

-
