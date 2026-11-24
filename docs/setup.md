<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  setup.md: Configure a new HADES archive and verify its first document.
  -->

# Set up your HADES archive 🗃️🔥

Use this guide for a new installation. An existing archive needs the [upgrade procedure](UPGRADING.md), its original signing key, and verified backups before images or database mounts change. The Department accepts new clerks; it does not accept improvised migrations.

## Before you start

Prepare the following before following the [README quickstart](../README.md#create-a-new-archive-):

- A trusted Linux Docker host or Synology NAS with Container Manager, a running Docker engine, and Docker Compose. On Synology, project deployment can use the GUI instead of a shell. Check that the selected image versions support your host architecture; Paperless v3 requires `x86-64-v2` on x86 hardware.
- Git to obtain the repository files, Python 3 to generate a secret, and permission to manage Docker. Make is optional for shortcuts. A GUI deployment can copy the repository files and generate the secret on another trusted computer.
- Private storage for PostgreSQL, Redis, documents, consumption, exports, trash, and companion data. Choose capacity and backup space for your archive; do not use production documents to test a new installation.
- Host user/group IDs that may write the Paperless, Redis, and Paperless-AI directories, plus permissions appropriate to the PostgreSQL image's database user. Avoid world-writable directories and broad recursive permission changes.
- A private browser access route and unused web ports. The defaults are `8777` for Paperless and `3747` for Paperless-AI. Complete initial setup behind restricted access; configure TLS and authentication before allowing remote access.

There is no local application build. `docker-compose.yml` pulls third-party images with the reviewed tags in `example.env`.

## Configure the required values

Copy `example.env` to `.env` only for a new installation. Edit the private copy in a local editor; never paste its contents into a public issue. The example uses configurable defaults, including Synology-specific paths that must be reviewed on any host.

1. Generate a unique `PAPERLESS_SECRET_KEY` of at least 32 characters with the README command and keep it stable. Recover an existing installation's key from its protected configuration or backup instead of replacing it.
2. Replace every `change-me` password. Keep `REDIS_PASSWORD` and the URL-encoded password in `PAPERLESS_REDIS` synchronized. The URL format is `redis://:<URL-encoded-password>@redis:6379`. Set the initial `PAPERLESS_ADMIN_USER` and `PAPERLESS_ADMIN_PASSWORD`; these configure first-time administrator creation, not an existing account's password reset.
3. Set `DEFAULT_UID`, `DEFAULT_GID`, and `TZ` for the host. Review every `*_PATH` value and create the corresponding host directories before starting. The example paths begin at `/volume1/docker/paperless-ngx/config/`; a clone elsewhere does not redirect those absolute paths.
4. Keep `POSTGRES_DATA_TARGET=/var/lib/postgresql` with the supplied PostgreSQL 18 pin. PostgreSQL 17 and below require `/var/lib/postgresql/data`. Changing this target or the database major on existing data requires the [database procedure](UPGRADING.md#review-postgresql-data-mounts).
5. Set `PAPERLESS_URL` and `PAPERLESS_CSRF_TRUSTED_ORIGINS` to the address you will actually open, including scheme and any non-default port. For trusted-LAN direct access, that is `http://<host-address>:8777` unless you change `PAPERLESS_WEBUI_PORT`. Replace `<host-address>` with your host's address. For a TLS reverse proxy, use its public HTTPS origin and the [upstream proxy settings](https://docs.paperless-ngx.com/configuration/).
6. Review the Docker subnet, range, and gateway. Defaults are `172.24.0.0/16`, `172.24.5.0/24`, and `172.24.5.254`. Choose a non-overlapping private network distinct from your LAN, VPN, and other Docker networks. If a Synology firewall filters bridge traffic, permit only the selected subnet and required web access.

Keep the remaining reviewed image pins and OCR/conversion defaults unless you have checked their requirements. The full [`example.env`](../example.env) and adjacent Compose comments own the settings reference. Internal Redis, PostgreSQL, Tika, and Gotenberg endpoints should remain private.

## Validate and start

From the repository root, follow the [README validation and startup commands](../README.md#create-a-new-archive-). `make config` checks your private `.env` and renders Compose quietly; `make validate` checks the public example with temporary test values. A passing public example check does not validate your passwords, storage permissions, or private deployment.

All six services start by default. Wait for initialization and inspect service logs locally. A healthy database alone does not prove that Paperless migrations, OCR, or search work. Never share unredacted logs, document names, URLs, paths, or secrets.

### Deploy with Synology Container Manager

1. Place the repository's deployment files on the NAS and prepare `.env` and all configured host paths as described above.
2. Open **Container Manager → Project → Create**, choose the project directory, and import `docker-compose.yml`.
3. Confirm the project reads the prepared `.env`; review the resulting services, ports, network, and host mounts before starting. Resolve missing substitutions rather than deploying placeholder values.
4. Create and start the project using the published images. Inspect Paperless initialization logs and status, then open the configured web address.
5. Complete the test-document procedure below.

### Deploy with Portainer

Use a Docker Standalone stack with the same root Compose file. Make the prepared `.env` values available through the stack's environment-file upload or variable editor, depending on your Portainer version. Host paths must exist on the Docker endpoint, which may differ from the computer running your browser. Review substitutions and mounted directories before deploying, keep the environment private, and verify initialization and the first document afterward. No Compose overlays or local image builds are required.

## File your first searchable document

1. Sign in to Paperless at your configured URL with the administrator credentials chosen for the new installation.
2. Create a non-sensitive, one-page image or scanned PDF containing a distinctive phrase such as “HADES approved the haunted sandwich.” Use an image without an embedded text layer to exercise OCR.
3. Upload it through Paperless's document upload control. Wait for consumption to finish and the document to appear in the archive.
4. Open the document and confirm its preview and extracted text. Search for `haunted sandwich` and confirm the document appears.
5. Download the original and confirm it opens and matches the uploaded file. If you rely on Office conversion, also test a synthetic Office document; image OCR does not verify Tika or Gotenberg.
6. Set up and test [protected backups](operations.md#back-up-and-verify-recovery) before adding irreplaceable documents.

If upload, OCR, search, preview, or download fails, use [troubleshooting](operations.md#troubleshoot-the-archive) before importing a large archive. The test receipt is expendable. Your tax records are not.

## Configure the optional Paperless-AI companion

The companion starts by default at `http://<host-address>:3747` unless you change `PAPERLESS_AI_WEBUI_PORT`. It is not required for Paperless OCR, search, or document management; Paperless-ngx v3 also has its own optional AI features.

1. Wait until the core archive passes the test-document procedure.
2. Open the companion through restricted access and complete its initial account and provider setup using the [Paperless-AI documentation](https://clusterzx.github.io/paperless-ai/).
3. Supply the Paperless API URL reachable from the companion (`http://paperless-ngx:8000` on this Compose network), a private token for a dedicated Paperless user with the document permissions required by your chosen features, and the selected provider credentials. Keep tokens and provider keys out of Git and public logs. Review the provider's document-data handling before enabling processing.
4. Confirm connection and process only a synthetic document first. Review resulting metadata before allowing automatic processing of your archive.

To leave the companion stopped while retaining the core archive, run from the repository root:

```sh
docker compose --env-file .env -f docker-compose.yml stop paperless-ai
```

A subsequent full `make up` or Compose `up` starts it again. Existing companions before `4.0.0` need the [security upgrade and recovery procedure](UPGRADING.md#upgrade-or-recover-paperless-ai), including a fresh data directory if compromise is suspected.
