#!/bin/sh

#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# check-env.sh: Validate private deployment settings before Compose starts the
#               Paperless-ngx stack.
#
# The script:
#   - Accepts an optional environment file path, defaulting to .env.
#   - Reads Compose-style assignments without sourcing or printing secrets.
#   - Rejects missing and known placeholder credentials.
#   - Enforces a minimum Paperless signing-key length.
#   - Rejects the example Redis URL and public Paperless hostname.
#   - Keeps the PostgreSQL image major version and data target synchronized.
#   - Reports every detected problem in one validation pass.
#

#
# Fail on errors and unset variables.
#
set -eu

#
# Script settings and validation policy.
#
ENV_FILE=${1:-${ENV_FILE:-.env}}
MINIMUM_SECRET_KEY_LENGTH=32
POSTGRES_LEGACY_DATA_TARGET=/var/lib/postgresql/data
POSTGRES_MODERN_DATA_TARGET=/var/lib/postgresql

# This policy contains setting names only, never credential values.
REQUIRED_SECRET_KEYS="REDIS_PASSWORD POSTGRES_PASSWORD PAPERLESS_ADMIN_PASSWORD PAPERLESS_SECRET_KEY"  # pragma: allowlist secret

#
# Script state used for consistent output and aggregated validation failures.
#
script_name=check-env.sh
failed=0

#
# Print a consistent status line without exposing configuration values.
#
log() {
    printf '[%s] %s\n' "${script_name}" "$*"
}

#
# Record one validation failure while allowing the remaining checks to run.
#
report_failure() {
    log "ERROR: $*" >&2
    failed=1
}

#
# Read one exact Compose-style assignment without sourcing the environment file.
# Remove one matching pair of outer quotes and unwrap the repository's
# ${VARIABLE:-default} example syntax before returning only the setting value.
#
read_value() {
    read_value_key=$1
    read_value_result=$(sed -n "s/^${read_value_key}=//p" "${ENV_FILE}" | tail -n 1)

    case "${read_value_result}" in
        \"*\")
            read_value_result=${read_value_result#\"}
            read_value_result=${read_value_result%\"}
            ;;
        \'*\')
            read_value_result=${read_value_result#\'}
            read_value_result=${read_value_result%\'}
            ;;
    esac

    case "${read_value_result}" in
        "\${"*":-"*"}")
            read_value_result=${read_value_result#*:-}
            read_value_result=${read_value_result%\}}
            ;;
    esac

    printf '%s' "${read_value_result}"
}

#
# Reject an absent environment file before attempting any setting checks.
#
if [ ! -f "${ENV_FILE}" ]; then
    log "ERROR: No ${ENV_FILE} found." >&2
    log "Copy example.env to ${ENV_FILE}, replace every placeholder, and retry." >&2
    exit 1
fi

#
# Reject required credentials that are empty or still use known example values.
#
for required_secret_key in ${REQUIRED_SECRET_KEYS}; do
    required_secret_value=$(read_value "${required_secret_key}")

    case "${required_secret_value}" in
        ""|change-me|change-me-*|redispass|paperlesspass|adminpass)
            report_failure "${required_secret_key} is missing or still uses an unsafe example value."
            ;;
    esac
done

#
# Require enough signing-key entropy for Paperless sessions and signed tokens.
# The key itself is never written to output.
#
paperless_secret_key=$(read_value PAPERLESS_SECRET_KEY)
paperless_secret_key_length=$(printf '%s' "${paperless_secret_key}" | wc -c | tr -d '[:space:]')

if [ "${paperless_secret_key_length}" -lt "${MINIMUM_SECRET_KEY_LENGTH}" ]; then
    report_failure "PAPERLESS_SECRET_KEY must contain at least ${MINIMUM_SECRET_KEY_LENGTH} characters."
fi

#
# Reject an absent Redis URL or one that still contains a repository placeholder.
#
paperless_redis=$(read_value PAPERLESS_REDIS)

case "${paperless_redis}" in
    ""|redis://:change-me-*|redis://redispass@*)
        report_failure "PAPERLESS_REDIS is missing or still uses an unsafe example value."
        ;;
esac

#
# Reject the documentation hostname so a new deployment cannot advertise a
# canonical URL that belongs to nobody in particular.
#
paperless_url=$(read_value PAPERLESS_URL)

case "${paperless_url}" in
    ""|*yourname.synology.me*)
        report_failure "PAPERLESS_URL is missing or still uses the example hostname."
        ;;
esac

#
# Extract the numeric PostgreSQL major version while tolerating a future image
# digest suffix. Validate the container data target against the image layout.
#
postgres_tag=$(read_value POSTGRES_TAG)
postgres_version=${postgres_tag%%@*}
postgres_major=${postgres_version%%.*}
postgres_data_target=$(read_value POSTGRES_DATA_TARGET)

case "${postgres_major}" in
    ""|*[!0-9]*)
        report_failure "POSTGRES_TAG must begin with a numeric major version."
        ;;
    *)
        if [ "${postgres_major}" -ge 18 ]; then
            if [ "${postgres_data_target}" != "${POSTGRES_MODERN_DATA_TARGET}" ]; then
                report_failure "PostgreSQL 18+ requires POSTGRES_DATA_TARGET=${POSTGRES_MODERN_DATA_TARGET}."
            fi
        elif [ "${postgres_data_target}" != "${POSTGRES_LEGACY_DATA_TARGET}" ]; then
            report_failure "PostgreSQL 17 and below require POSTGRES_DATA_TARGET=${POSTGRES_LEGACY_DATA_TARGET}."
        fi
        ;;
esac

#
# Return one failure after reporting every unsafe or incompatible setting.
#
if [ "${failed}" -ne 0 ]; then
    log "Update ${ENV_FILE}, then run make check-env again." >&2
    exit 1
fi

#
# Report success without echoing any private deployment value.
#
log "The private settings have passed inspection by the Infernal Records Office. 🔥🗃️"
