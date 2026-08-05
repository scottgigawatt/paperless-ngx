#!/bin/sh

#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# check-compose-env.sh: Keep Compose interpolation and example.env in sync.
#

set -eu

compose_file=${1:-docker-compose.yml}
env_file=${2:-example.env}
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/paperless-compose-env.XXXXXX")
trap 'rm -rf "${work_dir}"' EXIT HUP INT TERM

compose_keys=${work_dir}/compose-keys
env_keys=${work_dir}/env-keys
missing_keys=${work_dir}/missing-keys
unused_keys=${work_dir}/unused-keys

grep -Eo '\$\{[A-Z][A-Z0-9_]*' "${compose_file}" \
    | sed 's/^\${//' \
    | sort -u > "${compose_keys}"

sed -n 's/^\([A-Z][A-Z0-9_]*\)=.*/\1/p' "${env_file}" \
    | sort -u > "${env_keys}"

comm -23 "${compose_keys}" "${env_keys}" > "${missing_keys}"
comm -13 "${compose_keys}" "${env_keys}" > "${unused_keys}"

if [ -s "${missing_keys}" ]; then
    echo "Variables used by ${compose_file} but missing from ${env_file}:"
    sed 's/^/  - /' "${missing_keys}"
    exit 1
fi

if [ -s "${unused_keys}" ]; then
    echo "Variables declared by ${env_file} but unused by ${compose_file}:"
    sed 's/^/  - /' "${unused_keys}"
    exit 1
fi

echo "${compose_file} and ${env_file} declare the same variables."
