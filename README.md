<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  README.md: Operate the HADES Paperless-ngx document archive.
  -->

# HADES Paperless-ngx 🗃️🔥

**HADES: Highly Automated Document Extraction & Storage** turns receipts, statements, and other paperwork into a searchable archive on a Docker Compose host or Synology NAS. This repository supplies one deployment file for six published service images. Nobody escapes the paperwork—not even the paperwork.

<!-- markdownlint-disable MD033 -->
<hr />

<p align="center">
  <em>📜 Star this repo. The Department notices everything, especially unfiled receipts.</em>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/paperless-ngx/stargazers"><img src="https://img.shields.io/github/stars/scottgigawatt/paperless-ngx?style=social&amp;label=Stars&amp;logo=github&amp;logoColor=181717" alt="Repository stars" /></a>
  <a href="https://github.com/scottgigawatt/paperless-ngx/forks"><img src="https://img.shields.io/github/forks/scottgigawatt/paperless-ngx?style=social&amp;label=Forks&amp;logo=github&amp;logoColor=181717" alt="Repository forks" /></a>
  <a href="https://github.com/scottgigawatt/paperless-ngx/watchers"><img src="https://img.shields.io/github/watchers/scottgigawatt/paperless-ngx?style=social&amp;label=Watchers&amp;logo=github&amp;logoColor=181717" alt="Repository watchers" /></a>
  <a href="https://github.com/scottgigawatt/paperless-ngx/releases/latest"><img src="https://img.shields.io/github/v/release/scottgigawatt/paperless-ngx?style=social&amp;label=Release&amp;logo=github&amp;logoColor=181717" alt="Latest repository release" /></a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/scottgigawatt/paperless-ngx?label=Archive%20License&amp;style=flat&amp;logo=apache&amp;logoColor=white&amp;color=D7263D&amp;labelColor=D7263D" alt="Apache 2.0 license" /></a>
  <a href="https://github.com/scottgigawatt/paperless-ngx/commits/main"><img src="https://img.shields.io/github/last-commit/scottgigawatt/paperless-ngx?label=Last%20Scan&amp;style=flat&amp;logo=git&amp;logoColor=white&amp;color=C45100&amp;labelColor=C45100" alt="Latest commit" /></a>
  <a href="https://github.com/scottgigawatt/paperless-ngx"><img src="https://img.shields.io/github/repo-size/scottgigawatt/paperless-ngx?label=Filing%20Cabinet&amp;style=flat&amp;logo=github&amp;logoColor=white&amp;color=8C6900&amp;labelColor=8C6900" alt="Repository size" /></a>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/paperless-ngx/actions/workflows/validate-pr.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/paperless-ngx/validate-pr.yml?label=Validation&amp;style=flat&amp;logo=githubactions&amp;logoColor=white&amp;color=16823B&amp;labelColor=16823B" alt="Compose validation workflow status" /></a>
  <a href="https://securityscorecards.dev/viewer/?uri=github.com/scottgigawatt/paperless-ngx"><img src="https://img.shields.io/ossf-scorecard/github.com/scottgigawatt/paperless-ngx?label=OpenSSF%20Scorecard&amp;style=flat&amp;logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI%2BPHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAxIDIgNXY2YzAgNiA0LjMgMTAuMiAxMCAxMiA1LjctMS44IDEwLTYgMTAtMTJWNXptMCAzIDcgM3Y0YzAgNC4zLTIuOSA3LjctNyA5LjRDNy45IDE4LjcgNSAxNS4zIDUgMTFWN3oiLz48L3N2Zz4%3D&amp;logoColor=white&amp;color=007D9C&amp;labelColor=007D9C" alt="OpenSSF Scorecard score" /></a>
  <a href="docs/SECURITY.md"><img src="https://img.shields.io/badge/Security-View%20policy-5138B6?label=Security&amp;style=flat&amp;logo=github&amp;logoColor=white&amp;color=5138B6&amp;labelColor=5138B6" alt="Security policy and private reporting" /></a>
</p>

<p align="center">─── ⛧ ───</p>

<p align="center">
  <em>💀 Got rogue PDFs or rebellious receipts? Submit Form 666-B and <strong>Enter 🔥HADES🔥</strong>.</em>
</p>

<p align="center">
  <a href="https://discord.gg/BpEGzWwGYf"><img src="https://img.shields.io/discord/1403601106315116626?label=%F0%9F%94%A5HADES%F0%9F%94%A5&amp;style=flat&amp;logo=discord&amp;logoColor=white&amp;color=C42878&amp;labelColor=C42878" alt="HADES Discord community" /></a>
</p>

<hr />
<!-- markdownlint-enable MD033 -->

## Start here 🧭

- **New archive:** [install and configure HADES](docs/setup.md#before-you-start), then follow the quickstart below.
- **Existing archive:** [read the upgrade procedure](docs/UPGRADING.md) before pulling images. Paperless v3 requires an upgrade through `2.20.15`; PostgreSQL major changes require a database migration. Paperless-AI before `4.0.0` has an actively exploited setup vulnerability: follow its [upgrade and recovery procedure](docs/UPGRADING.md#upgrade-or-recover-paperless-ai).
- **Running archive:** [back up, operate, and troubleshoot](docs/operations.md).
- **Contributors:** [prepare tools and validate changes](docs/CONTRIBUTING.md).

## Create a new archive 🚀

You need Git, a running Docker installation with Compose, private writable storage, and Python 3 to generate a signing key. Make is optional. Check [host requirements, storage permissions, and required settings](docs/setup.md#before-you-start) first. This route downloads deployment files and runs published images; it does not build applications locally.

1. Get the deployment files and create a private settings file:

   ```sh
   git clone https://github.com/scottgigawatt/paperless-ngx.git
   cd paperless-ngx
   cp example.env .env
   python3 -c "import secrets; print(secrets.token_urlsafe(64))"
   ```

2. Save the generated value as `PAPERLESS_SECRET_KEY` in `.env`. Replace every `change-me` value, synchronize the Redis password and URL, and configure the [host paths, identity, web address, and network](docs/setup.md#configure-the-required-values). Create the configured host directories with appropriate write permissions. Keep `.env` private and include it in protected backups. Preserve an existing archive's original key.
3. Validate without displaying secrets, then pull and start all six services. The commands are chained so a failed check or pull prevents startup:

   ```sh
   sh test/check-env.sh .env &&
   sh test/check-compose-env.sh docker-compose.yml example.env &&
   docker compose --env-file .env -f docker-compose.yml config --quiet &&
   docker compose --env-file .env -f docker-compose.yml pull &&
   docker compose --env-file .env -f docker-compose.yml up --detach --remove-orphans &&
   docker compose --env-file .env -f docker-compose.yml ps &&
   docker compose --env-file .env -f docker-compose.yml logs --follow paperless-ngx
   ```

   Wait for database migrations and Paperless initialization to finish. Use **Ctrl+C** to stop following logs; the services keep running. With Make installed, `make config`, `make pull`, `make up`, `make ps`, and `make logs` provide the equivalent checks and lifecycle actions. Do not run bare `make`: its default target starts the stack.
4. Open your configured `PAPERLESS_URL`. On a trusted LAN without a reverse proxy, use `http://<host-address>:8777` after setting the URL and CSRF origin accordingly. Sign in with `PAPERLESS_ADMIN_USER` and the private `PAPERLESS_ADMIN_PASSWORD` selected for this new installation.
5. [File and search a test document](docs/setup.md#file-your-first-searchable-document). Confirm its preview, searchable text, and original download before adding private records.

Paperless-AI starts with the stack but is optional for core archiving. Keep its initial setup private and [configure or stop the companion](docs/setup.md#configure-the-optional-paperless-ai-companion) after the core archive works. The Oracle is on payroll; that does not grant it access to your filing cabinet.

## Meet the infernal civil service 📂

| Service | Responsibility |
| --- | --- |
| Paperless-ngx | Archive, OCR, search, workflows, and API |
| Paperless-AI | Optional document analysis, tagging, and archive chat |
| PostgreSQL | Application database: the Eternal Ledger |
| Redis | Background-task broker: the pneumatic tubes |
| Gotenberg | Office and email conversion to PDF |
| Apache Tika | Office document text and metadata extraction |

[`example.env`](example.env) owns the complete settings and reviewed image pins. `.env` holds your private overrides. Renovate proposes updates for review; Watchtower is disabled so application, database, broker, and companion upgrades remain coordinated.

## Read more and get help 📚

- [Setup](docs/setup.md): host prerequisites, settings, Synology Container Manager, Portainer, and first document.
- [Operations and troubleshooting](docs/operations.md): storage, backups, lifecycle commands, and recovery routes.
- [Upgrade guide](docs/UPGRADING.md): prerequisite versions, database migration boundaries, conversion compatibility, and companion security.
- [Security policy](docs/SECURITY.md): protect documents and report vulnerabilities privately.
- [Contributing](docs/CONTRIBUTING.md): checks, repository conventions, and pull requests.
- [Paperless-ngx configuration](https://docs.paperless-ngx.com/configuration/) and [administration](https://docs.paperless-ngx.com/administration/): upstream settings and application management.
- [Paperless-AI documentation](https://clusterzx.github.io/paperless-ai/): companion configuration and providers.

HADES remains inspired by [Marius Hosting](https://mariushosting.com/) and its [Paperless-ngx](https://mariushosting.com/synology-install-paperless-ngx-with-office-files-support/) and [Paperless-AI](https://mariushosting.com/how-to-install-paperless-ai-on-your-synology-nas/) guides, with repeatable validation, reviewed versions, and upgrade safeguards. Death is temporary; records retention is forever. 🗃️🔥
