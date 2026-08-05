# Contributing to the Filing Cabinet 🗃️

Contributions are welcome when they make this Paperless-ngx deployment safer,
clearer, or easier to operate on Docker Compose and Synology Container Manager.

## Before You Start

- Read the root [README](../README.md).
- Read the [upgrade guide](UPGRADING.md) before changing an image major version.
- Read the [security policy](SECURITY.md) before sharing logs or configuration.
- Check existing issues and pull requests for related work.

## Local Setup

```sh
git clone git@github.com:scottgigawatt/paperless-ngx.git
cd paperless-ngx
cp example.env .env
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

Put the generated value in `.env`, replace every `change-me` value, and configure
the Synology paths and reverse-proxy URL for your environment.

## Validation

Run the broad repository checks for Compose, environment, workflow, or dependency
changes:

```sh
make help
make validate
pre-commit run --all-files
git diff --check
```

`make validate` uses safe CI-only secret values to render `example.env`; it does
not start containers. Use `make config` to validate a private `.env` without
printing its contents.

## Style And Scope

- Preserve the README's document-archive and HADES identity.
- Keep code and configuration comments sober and precise.
- Use four-space indentation in shell scripts.
- Keep one complete root `docker-compose.yml` deployment artifact.
- Keep `example.env` ordered with the Compose service blocks.
- Pin service versions and let Renovate propose routine updates.
- Do not add project image publishing workflows; this repository builds no image.
- Do not add a dependency or security tool without a meaningful target.

## Pull Requests

Explain the operational change first, then repository-quality work. Include the
validation commands you ran and distinguish local checks from live deployment
tests. Major application or database upgrades must include the prerequisite
version, backup plan, migration notes, and rollback boundary.

Never include `.env`, documents, database files, API tokens, private hostnames,
or unredacted production logs. A paperwork kraken is acceptable; a leaked tax
return is not. 🔥
