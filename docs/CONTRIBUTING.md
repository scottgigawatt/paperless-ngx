<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  CONTRIBUTING.md: Contribution procedures for the HADES records office.
  -->

# Join the Infernal Clerical Union 🖋️🔥

Contributions are welcome when they make this Paperless-ngx deployment safer,
clearer, or easier to operate on Docker Compose and Synology Container Manager.
HADES accepts patches from mortals, demons, and unusually determined
accountants. Necromancers must still sign their commits.

## Before Touching the Sacred Stapler 📎

- Read the root [README](../README.md).
- Read the [upgrade guide](UPGRADING.md) before changing an image major version.
- Read the [security policy](SECURITY.md) before sharing logs or configuration.
- Check existing issues and pull requests for related work.

Failure to read the existing forms may result in your form being referred to the
Department of Forms About Other Forms, from which no ticket has ever returned.

## Establish a Local Summoning Circle 🕯️

```sh
git clone git@github.com:scottgigawatt/paperless-ngx.git
cd paperless-ngx
cp example.env .env
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

Put the generated value in `.env`, replace every `change-me` value, and configure
the Synology paths and reverse-proxy URL for your environment.

Never use production documents for development. The test receipt for one
haunted sandwich is sufficient; the Department does not need your tax return.

## Trial by Paperwork 🧪📚

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

A green check does not prove a live migration is safe. It proves the forms are
filled out correctly, which is already a supernatural achievement.

## Infernal Dress Code and Jurisdiction 🎩

- Preserve the README's document-archive and HADES identity.
- Keep code and configuration comments sober and precise.
- Use four-space indentation in shell scripts.
- Keep one complete root `docker-compose.yml` deployment artifact.
- Keep `example.env` ordered with the Compose service blocks.
- Pin service versions and let Renovate propose routine updates.
- Do not add project image publishing workflows; this repository builds no image.
- Do not add a dependency or security tool without a meaningful target.

Public documentation belongs to the **HADES Department of Infernal Records**
theme. Be extremely funny around the operational facts and extremely boring
inside them. A joke may introduce a backup command; it may not alter one.

## Submit Form PR-666 📜

Explain the operational change first, then repository-quality work. Include the
validation commands you ran and distinguish local checks from live deployment
tests. Major application or database upgrades must include the prerequisite
version, backup plan, migration notes, and rollback boundary.

Never include `.env`, documents, database files, API tokens, private hostnames,
or unredacted production logs. A paperwork kraken is acceptable; a leaked tax
return is not. 🔥

Once submitted, your request will be reviewed by the Eternal Change Advisory
Board. The Board is one maintainer, but the title tested well with consultants.
