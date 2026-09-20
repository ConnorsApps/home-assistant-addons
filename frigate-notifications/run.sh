#!/usr/bin/with-contenv bashio
# shellcheck shell=bash disable=SC2155
set -e

# Export VAR from an option, if set. Env beats config.yaml in the app.
opt() { if bashio::config.has_value "$2"; then export "$1=$(bashio::config "$2")"; fi; }

export CONFIG_PATH=/config/config.yaml
if ! bashio::fs.file_exists "${CONFIG_PATH}"; then
    cp /usr/share/frigate-notifications/config.example.yaml "${CONFIG_PATH}"
    bashio::log.fatal "No config.yaml yet; wrote an example to the app's config folder."
    bashio::log.fatal "Edit it (recipients, cameras, rules), then start the app again."
    bashio::exit.nok
fi

export HASS_URL=http://supervisor/core HASS_TOKEN="${SUPERVISOR_TOKEN}"

# No MQTT service is normal (external broker), but bashio logs it as an error.
bashio::log.level fatal
bashio::services.available mqtt && mqtt=true || mqtt=false
bashio::log.level info
if ${mqtt}; then
    scheme=tcp
    [ "$(bashio::services mqtt ssl)" = true ] && scheme=ssl
    export MQTT_BROKER="${scheme}://$(bashio::services mqtt host):$(bashio::services mqtt port)"
    export MQTT_USERNAME="$(bashio::services mqtt username)"
    export MQTT_PASSWORD="$(bashio::services mqtt password)"
else
    bashio::log.info "No MQTT service; using mqtt: from config.yaml."
fi

opt MEDIA_FRIGATE_URL frigate_url
opt MEDIA_PUBLIC_BASE_URL public_base_url
opt SLACK_BOT_TOKEN slack_bot_token
opt NTFY_URL ntfy_url
opt NTFY_TOKEN ntfy_token
opt DB_URL db_url
opt REDIS_URL redis_url

# Changing the key breaks sent media links, so generate it once and keep it.
opt MEDIA_SIGNING_KEY media_signing_key
if [ -z "${MEDIA_SIGNING_KEY:-}" ]; then
    key_file=/data/signing_key
    [ -s "${key_file}" ] ||
        (umask 077 && od -An -tx1 -N32 /dev/urandom | tr -d ' \n' > "${key_file}")
    export MEDIA_SIGNING_KEY="$(cat "${key_file}")"
fi

export TZ="${TZ:-$(bashio::info.timezone || true)}"

exec frigate-notifications
