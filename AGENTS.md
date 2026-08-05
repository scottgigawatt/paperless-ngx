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

Public Markdown uses the **HADES Department of Infernal Records** theme. In this
repository, HADES expands to **Highly Automated Document Extraction & Storage**:
an absurdly overstaffed underworld bureaucracy where receipts are summoned,
OCR is mandatory, PostgreSQL keeps the eternal ledger, Redis operates the
pneumatic tubes, Gotenberg runs the PDF forge, Tika translates cursed Office
files, and Paperless-AI is the optional oracle currently on administrative
leave.

Make the prose genuinely funny, theatrical, and visually readable while keeping
every command and operational claim exact. Reuse the same infernal-office
vocabulary throughout public Markdown rather than introducing unrelated themes.
Good recurring terms include:

- Infernal Records Office, Eternal Archive, or HADES for the deployment
- mortal archivist or clerk for the operator
- form, decree, filing ritual, or approved incantation for procedures
- Cerberus, the vault, or the archive gates for security boundaries
- filing demon, cursed paperwork, and eternal ledger for troubleshooting

Keep the centered badges, emoji, callouts, and existing Discord identity when
editing the root README. Use relevant emoji as scanning landmarks, especially
`🔥`, `🗃️`, `📜`, `🧾`, `🖋️`, `🔐`, `🐕`, and `💀`.

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

Project-owned scripts and configuration files begin with the established
copyright, Apache-2.0 notice, and filename summary block. Match this shape for
hash-commented files:

```text
#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# filename: Concise summary whose continuation lines align with the summary.
#           Continue only when the useful description does not fit one line.
#
```

Shell scripts place their shebang first, followed by one blank line and this
header. Markdown uses the equivalent established HTML comment. Do not add a
YAML document-start marker before the header.

Use framed comments for file-level sections and service introductions:

```yaml
#
# Explain the purpose or constraint of the section.
#
```

Use an unframed single-line comment for a block inside a service, such as
`# Define the container environment` or `# Mount persistent application data`.
Keep exactly one blank line between logical blocks. Do not insert blank lines
inside a short mapping or list unless they separate named subsections.

Inline comments use two spaces before `#`. Within one logical mapping or list,
pad the code so every inline `#` begins in the same column. Recalculate the
alignment whenever a line is added, removed, or renamed. Comments should state
the setting's purpose, default, security boundary, or compatibility constraint;
do not merely repeat the key name.

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
- Prefer exec-form `CMD` healthchecks. Use `CMD-SHELL` only when the probe
  inherently requires shell behavior, and document that constraint.
- Prefer an upstream application health endpoint over a port-only probe. Use
  the probe executable's native failure exit status instead of appending a
  redundant `|| exit 1`.
- Keep environment variables grouped by owning service and purpose.
- Keep `example.env` and Compose interpolation synchronized with
  `test/check-compose-env.sh`.
- Do not add image build or publish workflows: this repository publishes no
  project-owned image.

Compose formatting is part of the repository interface. Follow these exact
conventions:

- Use two-space YAML indentation and no document-start marker.
- Put shared `x-` anchors before `services`, each with a framed explanation.
- Put a framed introduction immediately before every service.
- Order service blocks as: image/container identity, special runtime or security
  settings, labels, environment, published ports, volumes, healthcheck, and
  `depends_on`. Omit unused blocks without leaving empty headings.
- Begin the identity group with `# Docker image and container information`.
- Separate every present service block with exactly one blank line.
- Expand multi-item commands and healthcheck tests as one YAML item per line.
  Do not use compact JSON-style arrays for those lists.
- Add a short block-purpose comment immediately above `environment`, `ports`,
  `volumes`, `healthcheck`, and `depends_on` when those blocks are present.
- Group environment keys by owner or purpose. Put a single unframed subsection
  comment above each group and one blank line between groups.
- Align inline comments within the identity group, each environment subsection,
  each volume list, each healthcheck setting group, and each dependency list.
- Keep two spaces between the longest code entry and the aligned inline comment.
- Preserve literal container ports, internal paths, and service names in
  Compose; expose deployment-specific host ports, host paths, credentials, and
  image tags through `example.env`.
- Keep the `example.env` sections in the same service order as Compose and use
  framed comments around every top-level setting group.
- Apply `no-new-privileges`, bounded logs, and explicit update policy through
  shared anchors. Do not add capabilities, host devices, privileged mode, or
  writable mounts without documenting why the service requires them.
- Keep Watchtower disabled for coordinated application, database, broker, and
  companion upgrades; this stack must be updated intentionally.

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

Match the Privateerr and Plundarr Makefile structure:

- Define uppercase variables for every public target in a framed `Makefile
  target names` section, followed by one multiline `TARGETS` list.
- Group service names, repository commands, Compose options, reusable commands,
  dependencies, and file paths into separate framed sections.
- Align `?=` operators within each related variable group.
- Use tabs for recipes and `TARGETS` continuation entries; use four spaces for
  indentation inside shell fragments embedded in recipes.
- Declare `.PHONY: $(TARGETS)` after centralized variables and helper functions.
- Give every target a framed comment. When it has prerequisite targets, include
  a dependency block in exactly this form:

```make
#
# $(TARGET): Short target description.
#
# Dependencies:
#   $(OTHER_TARGET) - Why this dependency is needed.
#
```

- Route public lifecycle commands through the shared Compose variables and
  options rather than repeating flags in recipes.
- Keep `make help` generated through the shared `help_line` function, ordered
  the same way as `TARGETS`.
- Never make stop, status, or log inspection depend on secret validation; those
  recovery commands must remain available when application configuration is
  broken.
- Do not add destructive cleanup targets that delete Paperless documents,
  PostgreSQL data, broker data, or other application state.

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

## GitHub Workflow Rules

- Pin GitHub Actions to full commit SHAs with readable version comments.
- Keep workflow permissions minimal and explicit.
- Use four-space indentation in `.github/workflows/*.yml`; the more compact
  two-space rule still applies to Compose and other YAML.
- Start every workflow with the established copyright, license, and filename
  summary block; do not add a YAML document-start marker.
- Explain trigger policy, job responsibility, and each logical step group with
  framed plain-English comments. Keep one blank line between those groups.
- Keep themed workflow and step names concise. Comments describing security or
  behavior remain sober and literal.
- Set a finite `timeout-minutes` on each job.
- Check out with `persist-credentials: false` and grant each job only the
  permissions required by its actions.
- Use Renovate rather than adding Dependabot for the same dependency set.
- Validate Compose, repository-owned scripts, YAML, secrets, and configuration
  policy on pull requests.
- Keep OpenSSF Scorecard as repository-level supply-chain analysis.
- Do not add CodeQL language scanning unless the repository later owns a
  supported production codebase.

Format `.github/renovate.json5` with four-space indentation. Separate schema,
scheduling, managers, custom managers, and package rules with one blank line and
a concise `//` comment explaining the policy of each section.

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
