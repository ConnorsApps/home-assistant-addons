#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# shellcheck disable=SC2155 # exporting straight from $(bashio::...) is the norm here; the app validates what it is given
set -e

# hass-backup reads its settings from the environment; this maps the app's
# options onto it. Home Assistant itself is reached through the Supervisor,
# which needs no URL or token to be configured.
export HASS_MODE=supervisor

export SCHEDULE="$(bashio::config 'schedule')"
export STORAGE_URL="$(bashio::config 'storage_url')"
export STORAGE_PREFIX="$(bashio::config 'storage_prefix')"
export RETENTION_KEEP_LAST="$(bashio::config 'retention_keep_last')"
export HASS_DELETE_AFTER_TRANSFER="$(bashio::config 'delete_after_transfer')"
export LOG_LEVEL="$(bashio::config 'log_level')"
export LOG_FORMAT=text

# The schedule is read in the container's time zone.
if [ -z "${TZ:-}" ]; then
    TZ="$(bashio::info.timezone)"
fi
export TZ

if bashio::config.has_value 'aws_endpoint_url'; then
    export AWS_ENDPOINT_URL="$(bashio::config 'aws_endpoint_url')"
fi
if bashio::config.has_value 'aws_region'; then
    export AWS_REGION="$(bashio::config 'aws_region')"
fi
if bashio::config.has_value 'aws_access_key_id'; then
    export AWS_ACCESS_KEY_ID="$(bashio::config 'aws_access_key_id')"
fi
if bashio::config.has_value 'aws_secret_access_key'; then
    export AWS_SECRET_ACCESS_KEY="$(bashio::config 'aws_secret_access_key')"
fi

# A relative name is a file in the app's config folder, /addon_configs/<id>_hass_backup/.
if bashio::config.has_value 'google_credentials_file'; then
    credentials="$(bashio::config 'google_credentials_file')"
    case "${credentials}" in
        /*) ;;
        *) credentials="/config/${credentials}" ;;
    esac
    if ! bashio::fs.file_exists "${credentials}"; then
        bashio::log.fatal "google_credentials_file ${credentials} does not exist."
        bashio::exit.nok
    fi
    export GOOGLE_APPLICATION_CREDENTIALS="${credentials}"
fi

bashio::log.info "Starting hass-backup: schedule '${SCHEDULE}', storage '${STORAGE_URL}'."
exec hass-backup
