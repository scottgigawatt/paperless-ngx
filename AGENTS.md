<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  AGENTS.md: Contributor and AI-agent operating instructions for this repository.
  -->

# AGENTS.md

## Project Purpose

This repository owns a single-file Docker Compose deployment for Paperless-ngx,
Paperless-AI, PostgreSQL, Redis, Gotenberg, and Apache Tika. It is designed for
Docker Compose, Synology Container Manager, and Portainer.

This repository does not build or modify the upstream applications. Treat the
service images as third-party dependencies and keep local changes focused on
deployment configuration, validation, documentation, and repository governance.

## Repository Layout

- `docker-compose.yml`: Complete deployable stack. Keep it usable as one file.
- `example.env`: Complete non-secret configuration example, ordered to follow
  the Compose service blocks.
- `.env`: Private deployment settings. Never commit it or print its values.
- `config/`: Runtime data directories retained with checked-in `.gitignore`
  files.
- `test/`: Repository-owned configuration and policy checks.
- `docs/`: Upgrade, contribution, security, and community guidance.
- `.github/`: Workflows, Renovate policy, ownership, and contribution templates.
- `Makefile`: Supported validation and stack lifecycle interface.

## Documentation Voice

Public Markdown should preserve the existing document-archive and HADES voice:
funny, a little theatrical, visually readable, and operationally precise. Keep
the centered badges, emoji, callouts, and existing Discord identity when editing
the root README.

Do not let jokes obscure commands, paths, warnings, backup steps, migration
requirements, or secret-handling rules. Use GitHub callouts where they improve
scanning:

- `[!NOTE]`
- `[!TIP]`
- `[!IMPORTANT]`
- `[!WARNING]`
- `[!CAUTION]`

## Code Comment Style

Code and configuration comments use concise plain English, not HADES or pirate
language. Explain intent, constraints, compatibility requirements, and
non-obvious behavior instead of narrating each assignment.

Project-owned scripts and configuration files should begin with the established
copyright, Apache-2.0 notice, and filename summary block. Shell scripts use four-
space indentation.

## Docker Compose Rules

Synology Container Manager compatibility and a single deployment artifact are
core constraints.

- Keep the complete deployment in root `docker-compose.yml`.
- Keep service image tags configurable through `example.env` and `.env`.
- Pin example image versions; do not use `latest` defaults.
- Let Renovate propose dependency updates for review.
- Keep defaults in environment files instead of inline Compose fallback syntax.
- Keep `POSTGRES_DATA_TARGET` aligned with the selected database major version:
  `/var/lib/postgresql/data` for PostgreSQL 17 and below, and
  `/var/lib/postgresql` for PostgreSQL 18 and above.
- Use directory mounts for application state.
- Reuse the shared restart, security, pull, and logging anchor when appropriate.
- Add healthchecks only when the image contains the required healthcheck tool.
- Keep environment variables grouped by owning service and purpose.
- Keep `example.env` and Compose interpolation synchronized with
  `test/check-compose-env.sh`.
- Do not add image build or publish workflows: this repository publishes no
  project-owned image.

## Paperless Upgrade Safety

Paperless upgrades can contain database migrations and behavioral changes.

- Read `docs/UPGRADING.md` and the official upstream migration guide before a
  major upgrade.
- Never skip a documented intermediate version. Paperless-ngx v3 specifically
  requires the database to be upgraded through v2.20.15 first.
- Never change the PostgreSQL major version and container data target as if they
  were an ordinary image update. Locate the active cluster, back it up, and use
  a supported database migration.
- Require a confirmed backup of PostgreSQL, Paperless data, media, exports, and
  `.env` before major upgrades.
- Keep `PAPERLESS_SECRET_KEY` stable after it is generated. Rotating it
  invalidates sessions and signed tokens.
- Review removed or renamed environment settings before changing a major image
  version.
- Expect the first v3 start to rebuild the full-text search index.
- Do not infer production migration success from a valid Compose render. Runtime
  logs and service health must also be checked on the deployment host.

## Secrets And Runtime Data

Never commit or expose:

- `.env`
- Paperless or Paperless-AI API tokens
- `PAPERLESS_SECRET_KEY`
- administrator, PostgreSQL, or Redis passwords
- documents, thumbnails, exports, database files, or broker data
- unredacted logs containing private document or infrastructure details

The values beginning with `change-me` in `example.env` are intentionally unsafe
placeholders. Generate the Paperless signing key with:

```sh
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

Never print a user's active `.env` while diagnosing configuration.

## Shell And Make Rules

Project-owned scripts should use `#!/bin/sh`, POSIX-compatible syntax, `set -eu`,
and four-space indentation. Use Bash only if a script intentionally needs Bash
features and its runtime guarantees Bash.

Keep Makefile variables centralized near the top. User-facing output may use a
light project flourish, but errors must name the problem and corrective action.

Supported commands include:

```sh
make help
make check-env
make config
make config-example
make validate
make pull
make up
make down
make restart
make ps
make logs
```

Do not add destructive cleanup targets that delete Paperless documents,
PostgreSQL data, or other application state.

## GitHub Workflow Rules

- Pin GitHub Actions to full commit SHAs with readable version comments.
- Keep workflow permissions minimal and explicit.
- Use Renovate rather than adding Dependabot for the same dependency set.
- Validate Compose, repository-owned scripts, YAML, secrets, and configuration
  policy on pull requests.
- Keep OpenSSF Scorecard as repository-level supply-chain analysis.
- Do not add CodeQL language scanning unless the repository later owns a
  supported production codebase.

Workflow and step names may use tasteful document, archive, or HADES theming.
Workflow comments remain plain English.

## Validation Expectations

For documentation-only changes, run:

```sh
pre-commit run --all-files
```

For Compose, environment, workflow, or dependency changes, run:

```sh
make help
make validate
pre-commit run --all-files
git diff --check
```

When a safe non-production deployment host is available, additionally run:

```sh
make config
make up
make ps
```

Inspect Paperless migration and health logs before calling an upgrade complete.
Do not start the user's production stack merely to validate a repository diff.

## Branch And Pull Request Conventions

Use funny project-themed branch and commit names that still describe the change.
PR descriptions should lead with the operational fix, separate migration notes
from repository-quality work, list validation evidence, and call out anything
that still requires execution on the deployment host.

Before opening a PR, inspect the complete diff, run the broad validation suite,
confirm no secret or runtime data is staged, assign `@scottgigawatt`, and use
existing repository labels instead of inventing new ones.

## Licensing

Project-owned files are Apache-2.0. Third-party containers and upstream projects
retain their own licenses; do not imply this repository relicenses them.
