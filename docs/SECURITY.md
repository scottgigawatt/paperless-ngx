<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  SECURITY.md: Security policy for the HADES Paperless-ngx deployment.
  -->

# Cerberus Guards the Archive 🐕🐕🐕🔐

Paperless stores sensitive documents in clear text on its storage volumes. Run
this stack only on a trusted host, protect backups, and restrict network access
with a reverse proxy, authentication, and firewall rules appropriate to the
deployment.

HADES employs Cerberus as Chief Information Security Officer. He has three
heads, zero patience for public databases, and an exemplary record of detecting
credential stuffing because he assumes every stranger is carrying snacks.

## Supported Circles of HADES 🔥

Security fixes target the current `main` branch and the pinned stable image
versions in `example.env`. Older local configurations and modified third-party
images are not maintained by this repository.

## Whisper to Cerberus, Not the Town Square 🤫

Do not open a public issue for credential leaks, authentication bypasses, exposed
documents, or other exploitable findings.

Use GitHub's private vulnerability reporting feature:

1. Open the repository's **Security** tab.
2. Choose **Report a vulnerability**.
3. Provide reproducible steps, affected versions, and redacted evidence.

You may also ask for a private contact route in
[🔥HADES🔥](https://discord.gg/BpEGzWwGYf), but do not paste sensitive details into
a public Discord channel.

Security reports receive serious handling even when the surrounding prose is
ridiculous. Include the smallest reproducible, fully redacted evidence set.

## Forbidden Offerings 🚫📜

- `.env` or `PAPERLESS_SECRET_KEY`
- administrator, PostgreSQL, Redis, AI-provider, or Paperless API credentials
- document contents, thumbnails, exports, or database files
- public URLs, proxy topology, or host paths that should remain private
- unredacted container logs containing document names or infrastructure details

If a value would make identity theft easier, Cerberus does not want it pasted
into GitHub. He cannot operate a credit-monitoring portal with his paws.

## Lock the Crypt Before Filing 🔒⚰️

- Replace every example password and generate a unique signing key.
- Keep the signing key stable and protected in backups.
- Pin reviewed image versions and merge Renovate updates only after validation.
- Back up and test restore procedures before application or database upgrades.
- Keep the PostgreSQL data target aligned with its major version and never prune
  an unidentified database volume.
- Keep GitHub Actions pinned to full commit SHAs with minimal permissions.
- Run `make check-env`, `make validate`, and pre-commit before deployment changes.
- Follow upstream Paperless security advisories and migration guides.
- Treat the currently unmaintained external Paperless-AI companion as optional,
  avoid public exposure, and reassess it against Paperless-ngx's built-in AI.

Paperless-ngx, Paperless-AI, PostgreSQL, Redis, Gotenberg, and Apache Tika are
third-party projects. Report upstream vulnerabilities to the affected project as
well as privately notifying this repository when its deployment guidance needs a
correction.

The Eternal Archive is allowed to be dramatic. Its incident response must not
be. Report privately, preserve evidence, rotate only what must be rotated, and
document the recovery before declaring the demons contained. 🛡️🔥
