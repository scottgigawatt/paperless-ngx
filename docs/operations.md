<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  operations.md: Operate, back up, and troubleshoot the HADES archive.
  -->

# Operate and recover the archive 🗃️🔐

Keep the Eternal Archive boring in production. Inspect status, protect backups, and make reviewed changes; save the theatrical screaming for the stationery budget.

## Find your data

Runtime data lives at the host paths in your private `.env`, not necessarily inside the checkout. The checked-in `config/` folders retain only `.gitignore` files:

```text
config/
├── paperless-ai/
└── paperless-ngx/
    ├── consume/
    ├── data/
    ├── db/
    ├── export/
    ├── media/
    ├── redis/
    └── trash/
```

PostgreSQL holds the application database; Paperless `media` holds document files, while `data` includes application/index state. Keep consumed inputs, exports, trash, Redis state, and companion data within the retention and backup policy appropriate to your deployment. Do not edit application-managed files or use the checked-in placeholder directories as evidence of where a running archive stores data.

## Back up and verify recovery

Before application or database upgrades, protect PostgreSQL, Paperless `data`, `media`, and `export`, the complete Paperless-AI data directory, and `.env` with its original signing key. Protect backup access as carefully as live documents; storage volumes contain clear-text records. Preserve pending consumption and retained trash if they are part of your recovery requirements.

1. Follow the [Paperless backup and export guidance](https://github.com/paperless-ngx/paperless-ngx/blob/v3.4.2/docs/administration.md#making-backups) and the [PostgreSQL backup documentation](https://www.postgresql.org/docs/current/backup.html). Create a consistent database backup coordinated with document storage. Copying live database files casually is not a logical database backup.
2. Keep a separate protected copy of the full companion data directory and required provider credentials. A Paperless document export does not include all stack services or deployment secrets, and API tokens are excluded. Follow the [versioned backup and import guidance](https://github.com/paperless-ngx/paperless-ngx/blob/v3.4.2/docs/administration.md#making-backups) and restore exports into the same Paperless version before upgrading.
3. Record the image versions and storage mapping needed to restore. Preserve the original `.env`; never publish it with a support request.
4. Restore into isolated paths and a separate, compatible test database. Confirm login, document counts, sample originals/previews, and search before trusting the backup. Do not test restoration over the live archive.

Changing `POSTGRES_TAG` or `POSTGRES_DATA_TARGET` does not migrate a database. If data seems to disappear after a mount change, preserve the current containers and volumes and follow [PostgreSQL data-mount recovery](UPGRADING.md#review-postgresql-data-mounts). Do not prune volumes or remove an unidentified database container.

An untested backup is an optimistic collection of bytes wearing a tiny safety vest. Compliance has rejected the vest as supporting evidence.

## Use lifecycle commands

Run commands from the repository root. Make is optional; discover supported shortcuts with:

```sh
make help
```

`make ps` reports service state and `make logs` follows logs. Both remain available when secret validation fails. Stop following logs with **Ctrl+C**; this does not stop the stack. For the core archive alone:

```sh
docker compose --env-file .env -f docker-compose.yml logs --follow paperless-ngx
```

`make config` validates the private settings and Compose file without printing resolved secrets. `make validate` checks the public example, not the operator's `.env`. Neither proves that a live migration, OCR, conversion, or recovery succeeds.

`make down` stops and removes the stack's containers and network without requesting volume deletion; configured bind-mounted application data remains. `make restart` performs a full down/up cycle and recreates containers with the active configuration. It is not an in-place process restart and does not rebuild the search index by itself. Bare `make` starts the entire stack.

Before `make pull`, `make up`, or `make restart` on an existing archive, follow the [upgrade procedure](UPGRADING.md). The stack disables Watchtower updates so changes can be coordinated. Do not add `--volumes`, delete host data, or use global pruning as a troubleshooting shortcut.

## Troubleshoot the archive

Inspect logs locally and share only the smallest redacted error needed. Remove document contents and names, credentials, private addresses, paths, and other personal information. Use the [security policy](SECURITY.md) for exploitable findings.

### Paperless reports a missing signing key

For an existing installation, recover `PAPERLESS_SECRET_KEY` from the previous protected configuration or backup first. Keep it stable: replacement invalidates sessions and signed tokens. Establish the last successful application version and follow the [Paperless v3 prerequisite](UPGRADING.md#prepare-the-paperless-ngx-v3-upgrade) before starting migrations.

For a genuinely new installation, generate the key with the [setup procedure](setup.md#configure-the-required-values), store it privately, then run `make check-env` and `make up`. Never paste the key into an issue or log.

### Paperless cannot connect to Redis

1. Inspect Redis state and logs with `make ps` and `make logs`.
2. Keep `REDIS_PASSWORD` and the URL-encoded password in `PAPERLESS_REDIS` synchronized. Password-only authentication uses `redis://:<URL-encoded-password>@redis:6379`.
3. Check the configured host directory's write permissions and that the Docker subnet does not overlap another network.

### Paperless fails after an upgrade

Confirm the prior v2 release was exactly `2.20.15` before migrating to v3. Review obsolete settings reported by `make check-env`, then inspect migrations and index-rebuild output. Follow the [current upgrade requirements and verification](UPGRADING.md) and [official v3 migration guide](https://docs.paperless-ngx.com/migration-v3/).

Do not repeatedly recreate a failing migration or downgrade an already migrated database without a supported recovery plan. Restore the verified pre-upgrade backup when the documented rollback boundary is reached. A healthy empty PostgreSQL instance is not evidence that the original archive survived.

### Login returns 403 or a proxy error

Confirm `PAPERLESS_URL` and `PAPERLESS_CSRF_TRUSTED_ORIGINS` match the browser origin, including scheme and port. Paperless v3 login rate limiting may also require trusted-proxy settings. Follow the [upstream configuration guide](https://docs.paperless-ngx.com/configuration/) for the actual proxy hop count and forwarded client-IP header rather than copying another host's trust settings.

### Upload, OCR, search, or conversion fails

Inspect Paperless consumption/task errors and the relevant service logs. Confirm configured input/output paths are writable, the chosen OCR language matches the test document, and any first-start search rebuild has completed. Reproduce with a synthetic document rather than posting the failing private record.

If only Office documents fail, inspect Tika and Gotenberg as well as Paperless and retain the [reviewed conversion compatibility pins](UPGRADING.md#keep-document-conversion-compatible). A passing healthcheck does not exercise Office-to-PDF/A conversion. If only the companion fails, [stop and investigate Paperless-AI](setup.md#configure-the-optional-paperless-ai-companion) while keeping the core archive available.
