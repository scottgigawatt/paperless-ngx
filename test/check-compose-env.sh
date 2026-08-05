#!/bin/sh

#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# check-compose-env.sh: Keep Docker Compose interpolation and example.env
#                       declarations synchronized.
#
# The script:
#   - Accepts optional Compose and example environment file paths.
#   - Extracts every ${VARIABLE} interpolation from the Compose deployment.
#   - Extracts environment keys without sourcing their values.
#   - Rejects duplicate example environment declarations.
#   - Reports variables missing from or unused by either deployment artifact.
#   - Removes all temporary comparison files on success, failure, or interruption.
#

#
# Fail on errors and unset variables.
#
set -eu

#
# Use bytewise sorting so sort and comm produce identical ordering everywhere.
#
LC_ALL=C
export LC_ALL

#
# Input files and script state used for consistent output.
#
COMPOSE_FILE=${1:-${COMPOSE_FILE:-docker-compose.yml}}
ENV_FILE=${2:-${EXAMPLE_ENV_FILE:-example.env}}
script_name=check-compose-env.sh
failed=0
work_dir=""

#
# Print a consistent status line for local validation and CI logs.
#
log() {
    printf '[%s] %s\n' "${script_name}" "$*"
}

#
# Remove only the temporary directory created by this script.
#
cleanup() {
    if [ -n "${work_dir}" ] && [ -d "${work_dir}" ]; then
        rm -rf -- "${work_dir}"
    fi
}

#
# Print a labeled key list and record one aggregated validation failure.
#
report_key_list() {
    report_key_list_label=$1
    report_key_list_path=$2

    log "ERROR: ${report_key_list_label}" >&2
    sed 's/^/  - /' "${report_key_list_path}" >&2
    failed=1
}

#
# Reject absent input files before creating temporary comparison state.
#
if [ ! -f "${COMPOSE_FILE}" ]; then
    log "ERROR: Compose file not found: ${COMPOSE_FILE}" >&2
    exit 1
fi

if [ ! -f "${ENV_FILE}" ]; then
    log "ERROR: Example environment file not found: ${ENV_FILE}" >&2
    exit 1
fi

#
# Create isolated comparison files and guarantee cleanup on every exit path.
#
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/paperless-compose-env.XXXXXX")
trap cleanup EXIT HUP INT TERM

COMPOSE_KEYS="${work_dir}/compose-keys"
ENV_KEYS_RAW="${work_dir}/env-keys-raw"
ENV_KEYS="${work_dir}/env-keys"
DUPLICATE_ENV_KEYS="${work_dir}/duplicate-env-keys"
MISSING_ENV_KEYS="${work_dir}/missing-env-keys"
UNUSED_ENV_KEYS="${work_dir}/unused-env-keys"

#
# Extract unique Compose interpolation keys without resolving or printing any
# environment value.
#
grep -Eo '\$\{[A-Z][A-Z0-9_]*' "${COMPOSE_FILE}" \
    | sed 's/^\${//' \
    | sort -u > "${COMPOSE_KEYS}"

#
# Extract raw example environment keys, retain duplicate evidence, and create
# the sorted unique list required by comm.
#
sed -n 's/^\([A-Z][A-Z0-9_]*\)=.*/\1/p' "${ENV_FILE}" > "${ENV_KEYS_RAW}"
sort "${ENV_KEYS_RAW}" | uniq -d > "${DUPLICATE_ENV_KEYS}"
sort -u "${ENV_KEYS_RAW}" > "${ENV_KEYS}"

#
# Compare both sorted key sets in each direction.
#
comm -23 "${COMPOSE_KEYS}" "${ENV_KEYS}" > "${MISSING_ENV_KEYS}"
comm -13 "${COMPOSE_KEYS}" "${ENV_KEYS}" > "${UNUSED_ENV_KEYS}"

#
# Report every parity problem in one pass so maintainers can repair the complete
# environment contract before rerunning validation.
#
if [ -s "${DUPLICATE_ENV_KEYS}" ]; then
    report_key_list "Variables declared more than once in ${ENV_FILE}:" "${DUPLICATE_ENV_KEYS}"
fi

if [ -s "${MISSING_ENV_KEYS}" ]; then
    report_key_list "Variables used by ${COMPOSE_FILE} but missing from ${ENV_FILE}:" "${MISSING_ENV_KEYS}"
fi

if [ -s "${UNUSED_ENV_KEYS}" ]; then
    report_key_list "Variables declared by ${ENV_FILE} but unused by ${COMPOSE_FILE}:" "${UNUSED_ENV_KEYS}"
fi

#
# Return one failure after reporting all duplicate, missing, and unused keys.
#
if [ "${failed}" -ne 0 ]; then
    log "Repair the environment contract, then run make check-compose-env again." >&2
    exit 1
fi

#
# Report one clear success line after both deployment artifacts agree.
#
log "Compose and example.env agree. The infernal filing index has no loose labels. 📇🔥"
