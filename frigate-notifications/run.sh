#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# shellcheck disable=SC2155 # exporting straight from $(bashio::...) is the norm here; the app validates what it is given
set -e

# The rules, recipients and cameras live in a config file, which is too
# structured for the options form. Everything the Supervisor already knows, and
# every secret set in the options, is passed in as environment variables, which
# frigate-notifications lets win over the same setting in that file.
export CONFIG_PATH=/config/config.yaml

if ! bashio::fs.file_exists "${CONFIG_PATH}"; then
    cp /usr/share/frigate-notifications/config.example.yaml "${CONFIG_PATH}"
    bashio::log.fatal "No config.yaml yet, so an example was written to it."
    bashio::log.fatal "Edit it for your recipients, cameras and rules, then start the app again."
    bashio::log.fatal "It is in the app's config folder: /addon_configs/<repository>_frigate_notifications/config.yaml"
    bashio::exit.nok
fi

# Home Assistant, through the Supervisor's Core API proxy.
export HASS_URL="http://supervisor/core"
export HASS_TOKEN="${SUPERVISOR_TOKEN}"

# No MQTT service is a normal answer (an external broker), but bashio logs it as
# an error, so quiet it for the one check.
bashio::log.level fatal
if bashio::services.available "mqtt"; then
    mqtt_service=true
else
    mqtt_service=false
fi
bashio::log.level info

if ${mqtt_service}; then
    scheme=tcp
    if [ "$(bashio::services mqtt ssl)" = "true" ]; then
        scheme=ssl
    fi
    export MQTT_BROKER="${scheme}://$(bashio::services mqtt host):$(bashio::services mqtt port)"
    export MQTT_USERNAME="$(bashio::services mqtt username)"
    export MQTT_PASSWORD="$(bashio::services mqtt password)"
    bashio::log.info "Using the MQTT broker from Home Assistant: ${MQTT_BROKER}"
else
    bashio::log.info "No MQTT service from Home Assistant; using mqtt: from config.yaml."
fi

if bashio::config.has_value 'frigate_url'; then
    export MEDIA_FRIGATE_URL="$(bashio::config 'frigate_url')"
fi
if bashio::config.has_value 'public_base_url'; then
    export MEDIA_PUBLIC_BASE_URL="$(bashio::config 'public_base_url')"
fi

# Signed media links stop working when the key changes, so one is generated on
# first start and kept across restarts and updates, unless the options set one.
if bashio::config.has_value 'media_signing_key'; then
    MEDIA_SIGNING_KEY="$(bashio::config 'media_signing_key')"
else
    key_file=/data/signing_key
    if ! bashio::fs.file_exists "${key_file}"; then
        (umask 077 && od -An -tx1 -N32 /dev/urandom | tr -d ' \n' > "${key_file}")
    fi
    MEDIA_SIGNING_KEY="$(cat "${key_file}")"
fi
export MEDIA_SIGNING_KEY

if bashio::config.has_value 'slack_bot_token'; then
    export SLACK_BOT_TOKEN="$(bashio::config 'slack_bot_token')"
fi
if bashio::config.has_value 'ntfy_url'; then
    export NTFY_URL="$(bashio::config 'ntfy_url')"
fi
if bashio::config.has_value 'ntfy_token'; then
    export NTFY_TOKEN="$(bashio::config 'ntfy_token')"
fi
if bashio::config.has_value 'db_url'; then
    export DB_URL="$(bashio::config 'db_url')"
fi
if bashio::config.has_value 'redis_url'; then
    export REDIS_URL="$(bashio::config 'redis_url')"
fi

if [ -z "${TZ:-}" ]; then
    TZ="$(bashio::info.timezone)"
fi
export TZ

bashio::log.info "Starting frigate-notifications."
exec frigate-notifications
