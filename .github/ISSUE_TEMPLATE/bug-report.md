---
name: "Infernal incident report 🐛🔥"
about: "Report a deployment, migration, or configuration demon"
title: "[BUG] "
labels: bug
assignees: scottgigawatt
---

<!--
  Copyright 2025-2026 Scott Gigawatt

  Licensed under the Apache License, Version 2.0.

  bug-report.md: Incident intake for the HADES records office.
  -->

# Form INC-404: Something Escaped the Filing Cabinet 🐛🗃️

## Problem

Describe the problem and when it began.

## Steps to reproduce

1.
2.
3.

## Expected result

What should have happened?

## Redacted evidence

Include relevant errors from `make config`, `make ps`, or service logs.

> [!WARNING]
> Remove documents, filenames, `.env` values, passwords, API tokens, signing
> keys, private URLs, host paths, and other personal information.

## Environment

- Repository release or commit:
- Deployment method (Compose, Container Manager, or Portainer):
- Paperless-ngx image tag:
- Paperless-AI image tag:
- PostgreSQL image tag:
- Redis image tag:
- Gotenberg / Tika image tags (for conversion failures):
- Synology DSM / OS version:
- Docker and Compose versions:
- Reverse proxy:
- Did `make config` pass?

## Upgrade context

- Previous known-good Paperless-ngx version:
- Target version:
- Required intermediate version completed:
- Backup verified before the change:

## Additional context

Anything else that helps reproduce and exorcise the paperwork. Please do not include an actual goat; CI minutes are expensive enough.
