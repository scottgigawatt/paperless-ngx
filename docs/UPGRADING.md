<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  UPGRADING.md: Safe upgrade rituals for the HADES Paperless-ngx deployment.
  -->

# Upgrade HADES Without Summoning Middle Management 🔥📁

Paperless upgrades may run irreversible database migrations. Treat the image tag
as application code, not as a decorative label. The most dangerous creature in
the underworld is not a filing demon; it is a confident operator with an
untested backup and `latest` in their clipboard.

## Before Every Séance 🕯️

1. Read the [Paperless-ngx administration guide](https://docs.paperless-ngx.com/administration/)
   and the release notes for the target version.
2. Back up PostgreSQL, `data`, `media`, `export`, Paperless-AI data, and `.env`.
3. Confirm the backup can be restored somewhere other than the live paths.
4. Record the currently running Paperless-ngx version.
5. Run `make config` and resolve every configuration error before pulling images.

> [!CAUTION]
> A valid Compose file is not proof that a database migration is safe. Never
> replace a major image version until the required upgrade path is confirmed.

HADES calls this the Change Control Ritual. It resembles ordinary preparation,
but the checklist is printed on heavier paper and everyone looks haunted.

## PostgreSQL Moved the Eternal Ledger Downstairs 🐘📚

The official PostgreSQL image requires different container mount targets:

| PostgreSQL version | `POSTGRES_DATA_TARGET`     |
| ------------------ | -------------------------- |
| 17 and below       | `/var/lib/postgresql/data` |
| 18 and above       | `/var/lib/postgresql`      |

Changing the image major and mount target does not migrate a database. If an
existing PostgreSQL 17 service was run with the parent `/var/lib/postgresql`
mount, Docker may have stored the active cluster in an anonymous volume declared
by the image. Recreating with the corrected bind target can then reveal older
host files while the newer cluster remains in the detached volume.

Before changing or recreating that service:

1. Stop application writes without deleting the current containers or volumes.
2. Identify the exact volume mounted at `/var/lib/postgresql/data` in the running
   PostgreSQL container.
3. Create and verify a logical database dump from that running cluster.
4. Copy or restore the dump into a correctly mounted, version-compatible target.
5. Only then remove obsolete containers or anonymous volumes.

> [!WARNING]
> Do not use `docker compose down --volumes`, prune volumes, or delete the old
> PostgreSQL container until the active cluster has been located and restored
> successfully. A healthy `pg_isready` response proves only that a database is
> accepting connections, not that it contains the expected Paperless records.

An empty healthy database is still empty. It is merely empty with excellent
posture.

## Pay the Paperless-ngx v3 Tollkeeper 🛑

The checked-in example currently pins Paperless-ngx `3.4.2`. Upstream requires
all v3 upgrades to start from `2.20.15`.

If the existing instance is older than `2.20.15`:

1. Set `PAPERLESS_TAG` in `.env` to `2.20.15`.
2. Pull and start that version.
3. Wait for migrations to finish and confirm Paperless is healthy.
4. Make and verify another backup.
5. Set `PAPERLESS_TAG` to the reviewed v3 version and continue below.

If the instance already attempted to pull v3 but stopped with
`PAPERLESS_SECRET_KEY is not set`, check the last successfully running version.
The reported startup failure occurs before v3 migrations, but that alone does
not prove the previous database version was `2.20.15`.

The tollkeeper accepts exactly one currency: evidence. Screaming "but Compose
pulled it successfully" is not evidence and only encourages him.

## Forge the Seal of the Eternal Archive 🔑🔥

Paperless-ngx v3 refuses to start without a unique signing key:

```sh
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

Store the output as `PAPERLESS_SECRET_KEY` in `.env`. Never commit it, post it in
an issue, or rotate it casually.

> [!WARNING]
> Replacing an existing signing key invalidates active sessions and other signed
> tokens. Keep the generated key with the rest of the deployment secrets and
> include `.env` in the protected backup plan.

Also replace the example Redis, PostgreSQL, and administrator passwords. Keep
`REDIS_PASSWORD` and the password embedded in `PAPERLESS_REDIS` synchronized. A
password-only Redis URL uses this form:

```text
redis://:<URL-encoded-password>@redis:6379
```

Do not laminate the signing key, post it beside the NAS, or tattoo it on the
intern. Store it in the protected secret and backup system.

## Read the New Infernal Bylaws 📜

This repository already sets the PostgreSQL engine explicitly and preserves the
old duplicate-rejection behavior. Review the remaining upstream changes before
starting v3:

- Duplicate documents are allowed by default upstream. This stack sets
  `PAPERLESS_CONSUMER_DELETE_DUPLICATES=true` to retain the v2 behavior.
- Consumer delay and ignore settings changed; ignore patterns are now regular
  expressions rather than `fnmatch` patterns.
- Several advanced database variables moved into `PAPERLESS_DB_OPTIONS`.
- OCR mode and archive-generation controls were separated.
- Document and thumbnail encryption is no longer supported; encrypted documents
  must be decrypted before the upgrade.
- Pre- and post-consumption scripts no longer receive positional arguments.
- The Whoosh index is replaced by Tantivy and is rebuilt on first startup.
- Existing task history is cleared during the upgrade.
- Reverse-proxy login rate limiting may require trusted-proxy settings.
- Saved searches that relied on unqualified note or custom-field matches may
  need explicit Tantivy field paths after the automatic migration.
- OpenID Connect providers may need an explicit `token_auth_method` if the
  callback begins returning `invalid_client`.
- Mail rules with `maximum_age` values above `32767` are clamped during the
  database migration.
- Older x86 hardware must meet the new `x86-64-v2` CPU baseline.

Read the complete [official v3 migration guide](https://docs.paperless-ngx.com/migration-v3/)
for the exact mappings and action items.

### Retire the v2 Forms Before They Haunt Payroll 👻📋

`make check-env` rejects the v2 settings below because Paperless-ngx v3 renamed,
removed, or deprecated them. Update `.env` before attempting the migration:

| Legacy v2 setting                                                                                                                              | v3 action                                               |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `PAPERLESS_CONSUMER_POLLING`                                                                                                                   | Use `PAPERLESS_CONSUMER_POLLING_INTERVAL`               |
| `PAPERLESS_CONSUMER_INOTIFY_DELAY`                                                                                                             | Use `PAPERLESS_CONSUMER_STABILITY_DELAY`                |
| `PAPERLESS_CONSUMER_POLLING_DELAY`                                                                                                             | Use `PAPERLESS_CONSUMER_STABILITY_DELAY`                |
| `PAPERLESS_CONSUMER_POLLING_RETRY_COUNT`                                                                                                       | Remove it; v3 tracks file stability automatically       |
| `PAPERLESS_CONSUMER_BARCODE_SCANNER`                                                                                                           | Remove it; v3 uses `zxing-cpp` exclusively              |
| `PAPERLESS_DBSSLMODE`, `PAPERLESS_DBSSLROOTCERT`, `PAPERLESS_DBSSLCERT`, `PAPERLESS_DBSSLKEY`, `PAPERLESS_DB_POOLSIZE`, `PAPERLESS_DB_TIMEOUT` | Move the equivalent options into `PAPERLESS_DB_OPTIONS` |
| `PAPERLESS_OCR_SKIP_ARCHIVE_FILE`                                                                                                              | Use `PAPERLESS_ARCHIVE_FILE_GENERATION`                 |

The example configuration explicitly sets `PAPERLESS_OCR_MODE=auto` and
`PAPERLESS_ARCHIVE_FILE_GENERATION=auto`. These preserve upstream v3's automatic
decision-making while making the deployment policy reviewable instead of
leaving it in an invisible desk drawer.

> [!IMPORTANT]
> Do not mechanically rename a retired setting without reading its v3 behavior.
> The new stability detector, database options mapping, and archive-generation
> policy are not all one-for-one substitutions. HADES has rejected Form 27-B,
> "It Had Basically the Same Name," for being how incidents get promoted.

## Keep the Conversion Clerks Compatible 📄

Use the reviewed Gotenberg `8.40.0` and Apache Tika `3.3.3.0` pins with Paperless-ngx `3.4.2`. Newer major versions are available, but their APIs differ from the clients bundled with this Paperless release. Gotenberg 9 removes the `pdfa` form field used for archival conversion; Tika 4 removes the `/tika/form` endpoint used by the current Tika client. A green healthcheck or Compose validation does not exercise those conversion paths.

Leave the [Gotenberg 9 proposal](https://github.com/scottgigawatt/paperless-ngx/pull/37) as a draft until Paperless and its clients support the new APIs and a disposable Office-to-PDF/A conversion succeeds. Review the [Gotenberg migration guide](https://gotenberg.dev/docs/getting-started/upgrade) and [Paperless Tika 4 compatibility report](https://github.com/paperless-ngx/paperless-ngx/issues/13755) before changing either major version. Keep compatible patch and security updates under review; do not disable archival output to make an incompatible update pass.

## Return the Oracle With a Security Badge 🔮

[Paperless-AI `4.0.0`](https://github.com/clusterzx/paperless-ai/releases/tag/v4.0.0) restores maintained support for Paperless-ngx 2.x and 3.x and fixes the unauthenticated setup takeover affecting all earlier versions. Upstream reports active exploitation. Review its [v4 migration and recovery guide](https://github.com/clusterzx/paperless-ai/blob/v4.0.0/README.md#upgrading-from-3x) before changing an existing deployment.

1. Stop the companion and back up its complete `PAPERLESS_AI_CONFIG_PATH` directory separately from the core archive backup.
2. If an internet-reachable v3 instance has unexpected credentials or endpoints, preserve the old data for investigation and configure v4 with a new empty data directory. Replace its Paperless API token and AI-provider keys and review access logs. Do not migrate suspected compromised settings.
3. Set `PAPERLESS_AI_TAG=4.0.0` in `.env`. Keep the existing `/app/data` mount for trusted migrations. V4 imports legacy state at first start and retains the old files; its rebuilt search index can download an embedding model.
4. Remove obsolete `PUID`, `PGID`, and `RAG_SERVICE_URL` companion settings and `RAG_SERVICE_ENABLED` unless an environment override is intentional. The checked-in Compose service now runs with `DEFAULT_UID:DEFAULT_GID`; ensure that identity can write the companion data directory. Its healthcheck uses Node, which is included in v4.
5. Start only the companion after the core archive is healthy. Confirm migration messages, sign in with the existing account, review settings, and test with a non-sensitive document. Complete initial setup behind restricted access.

Configuration rollback does not undo document metadata already changed by the companion. The retained v3 files also omit changes made in v4; keep the verified backup until the migration is accepted.

The Oracle has returned from administrative leave. Security has confiscated its master key.

## Raise the New Stack Carefully ⚡

After the backup, prerequisite version, secret, and settings are confirmed:

```sh
make pull
make up
make ps
make logs
```

Confirm all of the following before considering the upgrade complete:

- PostgreSQL and Redis report healthy.
- Paperless migrations finish without an exception.
- Paperless reports healthy after the search-index rebuild.
- The web interface accepts a login through the configured reverse proxy.
- Existing documents, previews, search, consumption, and export work.
- Paperless-AI can still reach the Paperless API and process a safe test document.

If Paperless-AI fails against v3, stop that companion while keeping the core
Paperless, PostgreSQL, Redis, Tika, and Gotenberg services running. Do not treat
an optional integration as a reason to roll a healthy core archive
back without first separating the failures.

Keep the pre-upgrade backup until normal operation has been verified for several
days. A green healthcheck is delightful; a tested restore is better. The former
is a light on a dashboard. The latter is how you avoid explaining data loss to
the Four Horsemen of Compliance. 🗃️🔥
