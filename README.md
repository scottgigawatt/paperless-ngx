<hr />

<p align="center">
  <em>📜 Star this repo to keep your docs in line and your chaos in check.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/scottgigawatt/paperless-ngx?label=Archive%20License&color=blue" alt="License" />
  <img src="https://img.shields.io/github/last-commit/scottgigawatt/paperless-ngx?label=Last%20Scan&logo=git&color=green" alt="Last Commit" />
  <img src="https://img.shields.io/github/repo-size/scottgigawatt/paperless-ngx?label=Filing%20Cabinet&color=orange" alt="Repo Size" />
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/paperless-ngx/actions/workflows/validate-pr.yml">
    <img src="https://github.com/scottgigawatt/paperless-ngx/actions/workflows/validate-pr.yml/badge.svg" alt="Compose validation" />
  </a>
  <a href="https://securityscorecards.dev/viewer/?uri=github.com/scottgigawatt/paperless-ngx">
    <img src="https://api.securityscorecards.dev/projects/github.com/scottgigawatt/paperless-ngx/badge" alt="OpenSSF Scorecard" />
  </a>
</p>

<p align="center">─── ⛧ ───</p>

<p align="center">
  <em>💀 Got rogue PDFs or rebellious receipts? Cast them into the fire and <strong>Enter 🔥HADES🔥</strong>.</em>
</p>

<p align="center">
  <a href="https://discord.gg/BpEGzWwGYf">
    <img src="https://img.shields.io/discord/1403601106315116626?label=%F0%9F%94%A5HADES%F0%9F%94%A5&logo=discord&logoColor=white&color=5865F2" alt="🔥HADES🔥 Discord" />
  </a>
</p>

<hr />

# Paperless-ngx 🗃️🤖

Turn receipts, statements, manuals, and other paper clutter into a searchable
digital archive on a Synology NAS or any Docker Compose host. This repository
provides one complete deployment file for Paperless-ngx, Paperless-AI,
PostgreSQL, Redis, Gotenberg, and Apache Tika.

It remains inspired by the Synology guides from
[Marius Hosting](https://mariushosting.com/) while adding repeatable validation,
version management, safer upgrades, and repository governance.

## What Is In The Cabinet? 📂

| Service | Purpose | Default image version |
| ------- | ------- | --------------------- |
| Paperless-ngx | Document archive, OCR, search, workflows, and API | `3.0.5` |
| Paperless-AI | Legacy external AI analysis and tagging companion | `3.0.9` |
| PostgreSQL | Paperless application database | `18.4` |
| Redis | Broker for background and scheduled work | `8.8.1` |
| Gotenberg | Office and email conversion to PDF | `8.34.0` |
| Apache Tika | Office document text and metadata extraction | `3.2.3.0` |

All image versions are configurable in `.env`. The example pins reviewed
versions instead of floating `latest`, and Renovate proposes future updates as
reviewable pull requests.

> [!NOTE]
> Paperless-ngx v3 includes its own optional AI features. The separate
> Paperless-AI service remains in this stack for users who intentionally use its
> workflow and interface; it is not required for core Paperless operation.

> [!WARNING]
> The [Paperless-AI upstream project](https://github.com/clusterzx/paperless-ai)
> currently describes itself as unmaintained. Its latest `3.0.9` release is the
> newest available image, not a guarantee of Paperless-ngx v3 compatibility.
> Existing users should validate it separately with non-sensitive test data and
> consider a planned move to Paperless-ngx's built-in AI features.

## Stop Before Upgrading To v3 🛑

Paperless-ngx v3 requires `PAPERLESS_SECRET_KEY` and can only migrate from
version `2.20.15`.

> [!CAUTION]
> If this is an existing installation, do not simply pull the v3 image. Read
> [Upgrading Paperless-ngx](docs/UPGRADING.md), verify the last successful
> version, complete the `2.20.15` prerequisite when needed, and test a full
> backup before starting migrations.

> [!CAUTION]
> PostgreSQL 17 and below must mount `/var/lib/postgresql/data`; PostgreSQL 18+
> must mount `/var/lib/postgresql`. If this project previously ran PostgreSQL 17
> with the newer parent mount, inspect Docker's active volumes and make a logical
> database backup before any Compose recreate. Changing the mount can hide the
> current cluster and reveal older files that merely look like the same database.

The v3 upgrade also changes duplicate handling, consumer settings, OCR/archive
options, advanced database options, search indexing, task history, consume
scripts, and some reverse-proxy behavior. The repository preserves the old
duplicate-rejection behavior with
`PAPERLESS_CONSUMER_DELETE_DUPLICATES=true`; the other changes require review
against the private deployment.

## Quick Start For A New Installation 🚀

### 1. Prepare The Environment

```sh
cp example.env .env
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

Edit `.env` and:

- store the generated output as `PAPERLESS_SECRET_KEY`;
- replace every value beginning with `change-me`;
- keep the Redis password and the password inside `PAPERLESS_REDIS` identical;
- align `POSTGRES_DATA_TARGET` with the selected PostgreSQL major version;
- set the Synology host paths, UID, GID, timezone, URL, and network range;
- URL-encode special characters used inside `PAPERLESS_REDIS`.

> [!IMPORTANT]
> Keep `PAPERLESS_SECRET_KEY` stable and backed up. Rotating it invalidates
> active sessions and other signed tokens.

Validate the private settings without printing them:

```sh
make check-env
make config
```

### 2. Start With Docker Compose

```sh
make pull
make up
make ps
```

Follow the first startup until database migrations and the Paperless healthcheck
finish:

```sh
make logs
```

### 3. Import With Synology Container Manager

1. Place `docker-compose.yml`, `.env`, and the checked-in `config/` directory in
   the project folder on the NAS.
2. Open **Container Manager → Project → Create**.
3. Choose the project path and import `docker-compose.yml`.
4. Review the rendered services, ports, volumes, and private subnet.
5. Build the project and inspect the Paperless logs before logging in.

The same root `docker-compose.yml` is also suitable for a Portainer stack. No
overlay files or generated Compose fragments are required.

## Configuration 🧭

The root [`example.env`](example.env) is the complete settings reference for this
deployment. The most important groups are:

- private Docker network and Synology firewall range;
- container identity, timezone, and log rotation;
- pinned service image versions;
- Redis, PostgreSQL, administrator, and Paperless signing secrets;
- reverse-proxy URL and CSRF origin;
- OCR, duplicate, task-worker, and Office parsing behavior;
- persistent host paths and published web ports.

Paperless-ngx listens on `${PAPERLESS_WEBUI_PORT}` and Paperless-AI listens on
`${PAPERLESS_AI_WEBUI_PORT}`. Put internet-facing access behind a properly
configured TLS reverse proxy; do not expose internal Redis, PostgreSQL, Tika, or
Gotenberg ports.

### Network And Synology Firewall

The example reserves:

```text
Subnet:  172.24.0.0/16
Range:   172.24.5.0/24
Gateway: 172.24.5.254
```

Choose an unused private subnet that does not overlap the NAS, VPN, LAN, or
another Docker network. If the Synology firewall filters Docker bridge traffic,
allow only the selected subnet and necessary published web ports.

## Repository Commands 🛠️

```text
make help             Show supported commands
make check-env        Reject missing and placeholder private settings
make config           Validate docker-compose.yml with .env
make config-example   Validate the checked-in example with CI-only secrets
make validate         Run repository-owned configuration checks
make pull             Pull configured image versions
make up               Start or update the stack
make down             Stop the stack without deleting application data
make restart          Recreate the stack
make ps               Show service health and status
make logs             Follow logs from the stack
```

`make down` deliberately avoids `--volumes`. This project does not provide a
one-command nuke target for irreplaceable documents and database state. HADES
has standards. 🔥

## Persistent Data And Backups 💾

The checked-in directories retain only `.gitignore` files. Live data belongs in
the host paths configured by `.env`:

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

Back up PostgreSQL, Paperless `data`, `media`, and `export`, Paperless-AI data,
and `.env`. Test restoration away from the live paths before relying on the
backup. PostgreSQL major-version upgrades require their own reviewed migration;
changing `POSTGRES_TAG` is not a database upgrade plan.

## Troubleshooting 🔎

### `PAPERLESS_SECRET_KEY is not set`

Paperless-ngx v3 refuses to start without a unique signing key. Generate it,
store it in `.env`, then recreate the service:

```sh
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
make check-env
make up
```

Do not paste the generated value into an issue or log.

### Paperless Cannot Reach Redis

- Confirm Redis is healthy with `make ps`.
- Keep `REDIS_PASSWORD` and the password in `PAPERLESS_REDIS` synchronized.
- Use `redis://:<URL-encoded-password>@redis:6379` for password-only auth.
- Confirm the custom subnet does not overlap another network.

### Paperless Is Unhealthy After An Upgrade

- Check that the prior v2 release was exactly `2.20.15` before v3 migration.
- Inspect migration and index-rebuild output with `make logs`.
- Review the [official v3 migration guide](https://docs.paperless-ngx.com/migration-v3/).
- Restore the verified pre-upgrade backup if the documented rollback boundary is
  reached; do not repeatedly restart a failing migration and hope it becomes
  paperwork jazz.

### Reverse Proxy Login Returns `403`

Confirm `PAPERLESS_URL` and `PAPERLESS_CSRF_TRUSTED_ORIGINS`. Paperless v3 may
also require trusted-proxy settings for login rate limiting; follow the upstream
configuration guide for the actual proxy hop count and forwarded client-IP
header.

## Project Guides 📚

- [Upgrading Paperless-ngx](docs/UPGRADING.md)
- [Contributing](docs/CONTRIBUTING.md)
- [Security policy](docs/SECURITY.md)
- [Paperless-ngx configuration](https://docs.paperless-ngx.com/configuration/)
- [Paperless-ngx administration](https://docs.paperless-ngx.com/administration/)
- [Paperless-AI documentation](https://clusterzx.github.io/paperless-ai/)
- [Marius Hosting Paperless-ngx guide](https://mariushosting.com/synology-install-paperless-ngx-with-office-files-support/)
- [Marius Hosting Paperless-AI guide](https://mariushosting.com/how-to-install-paperless-ai-on-your-synology-nas/)

Bring order to the archive, keep secrets out of the fire, and may every OCR job
find its correspondent. 🗃️🔥
