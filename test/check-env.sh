#!/bin/sh

#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# check-env.sh: Reject missing or placeholder deployment secrets before start.
#

set -eu

env_file=${1:-.env}

if [ ! -f "${env_file}" ]; then
    echo "No ${env_file} found. Copy example.env to .env and configure it."
    exit 1
fi

read_value() {
    key=$1
    value=$(sed -n "s/^${key}=//p" "${env_file}" | tail -n 1)

    case "${value}" in
        \"*\") value=${value#\"}; value=${value%\"} ;;
        \'*\') value=${value#\'}; value=${value%\'} ;;
    esac

    case "${value}" in
        "\${"*":-"*"}")
            value=${value#*:-}
            value=${value%\}}
            ;;
    esac

    printf '%s' "${value}"
}

failed=0

for key in REDIS_PASSWORD POSTGRES_PASSWORD PAPERLESS_ADMIN_PASSWORD PAPERLESS_SECRET_KEY; do
    value=$(read_value "${key}")

    case "${value}" in
        ""|change-me|change-me-*|redispass|paperlesspass|adminpass)
            echo "${key} is missing or still uses an unsafe example value."
            failed=1
            ;;
    esac
done

secret_key=$(read_value PAPERLESS_SECRET_KEY)
secret_length=$(printf '%s' "${secret_key}" | wc -c | tr -d ' ')
if [ "${secret_length}" -lt 32 ]; then
    echo "PAPERLESS_SECRET_KEY must contain at least 32 characters."
    failed=1
fi

redis_url=$(read_value PAPERLESS_REDIS)
case "${redis_url}" in
    redis://:change-me-*|redis://redispass@*|"")
        echo "PAPERLESS_REDIS is missing or still uses an unsafe example value."
        failed=1
        ;;
esac

paperless_url=$(read_value PAPERLESS_URL)
case "${paperless_url}" in
    *yourname.synology.me*|"")
        echo "PAPERLESS_URL is missing or still uses the example hostname."
        failed=1
        ;;
esac

postgres_tag=$(read_value POSTGRES_TAG)
postgres_major=${postgres_tag%%.*}
postgres_data_target=$(read_value POSTGRES_DATA_TARGET)

case "${postgres_major}" in
    ''|*[!0-9]*)
        echo "POSTGRES_TAG must begin with a numeric major version."
        failed=1
        ;;
    *)
        if [ "${postgres_major}" -ge 18 ]; then
            if [ "${postgres_data_target}" != "/var/lib/postgresql" ]; then
                echo "PostgreSQL 18+ requires POSTGRES_DATA_TARGET=/var/lib/postgresql."
                failed=1
            fi
        elif [ "${postgres_data_target}" != "/var/lib/postgresql/data" ]; then
            echo "PostgreSQL 17 and below require POSTGRES_DATA_TARGET=/var/lib/postgresql/data."
            failed=1
        fi
        ;;
esac

if [ "${failed}" -ne 0 ]; then
    echo "Update ${env_file}, then run make check-env again."
    exit 1
fi

echo "${env_file} contains non-placeholder deployment settings."
