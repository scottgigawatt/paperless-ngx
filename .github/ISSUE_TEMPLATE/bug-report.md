---
name: "Bug report from the records room 🐛"
about: "Report a broken deployment, migration, or configuration"
title: "[BUG] "
labels: bug
assignees: scottgigawatt
---

**What broke?**
Describe the problem and when it began.

**Steps to reproduce**
1.
2.
3.

**Expected result**
What should have happened?

**Redacted logs or output**
Include relevant errors from `make config`, `make ps`, or service logs.

> [!WARNING]
> Remove documents, filenames, `.env` values, passwords, API tokens, signing
> keys, private URLs, host paths, and other personal information.

**Environment**

- Paperless-ngx image tag:
- Paperless-AI image tag:
- PostgreSQL image tag:
- Redis image tag:
- Synology DSM / OS version:
- Docker and Compose versions:
- Reverse proxy:
- Did `make config` pass?

**Upgrade context**

- Previous known-good Paperless-ngx version:
- Target version:
- Required intermediate version completed:
- Backup verified before the change:

**Extra clues**
Anything else that helps exorcise the paperwork.
