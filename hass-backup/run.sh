#!/usr/bin/with-contenv bashio
# shellcheck shell=bash disable=SC2155
set -e

# Export VAR from an option, if set.
opt() { if bashio::config.has_value "$2"; then export "$1=$(bashio::config "$2")"; fi; }

export HASS_MODE=supervisor LOG_FORMAT=text
opt SCHEDULE schedule
opt STORAGE_URL storage_url
opt STORAGE_PREFIX storage_prefix
opt RETENTION_KEEP_LAST retention_keep_last
opt HASS_DELETE_AFTER_TRANSFER delete_after_transfer
opt HASS_TIMEOUT timeout
opt LOG_LEVEL log_level
opt AWS_ENDPOINT_URL aws_endpoint_url
opt AWS_REGION aws_region
opt AWS_ACCESS_KEY_ID aws_access_key_id
opt AWS_SECRET_ACCESS_KEY aws_secret_access_key

export TZ="${TZ:-$(bashio::info.timezone || true)}"
[ -n "${TZ}" ] || bashio::log.warning "Could not read Home Assistant's time zone; using UTC."

# A relative name is a file in the app's config folder.
if bashio::config.has_value google_credentials_file; then
    credentials="$(bashio::config google_credentials_file)"
    case "${credentials}" in /*) ;; *) credentials="/config/${credentials}" ;; esac
    bashio::fs.file_exists "${credentials}" || {
        bashio::log.fatal "google_credentials_file ${credentials} does not exist."
        bashio::exit.nok
    }
    export GOOGLE_APPLICATION_CREDENTIALS="${credentials}"
fi

exec hass-backup
