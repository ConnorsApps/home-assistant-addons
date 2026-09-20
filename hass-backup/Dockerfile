# The app is the published hass-backup binary (built with every storage driver)
# dropped into the Home Assistant base image, which brings s6-overlay and bashio
# for reading the app's options. Bump SOURCE_VERSION together with `version` in
# config.yaml when taking a new hass-backup release.
ARG SOURCE_VERSION=0.2.0

FROM ghcr.io/connorsapps/home-assistant-backup:${SOURCE_VERSION}-all AS source

FROM ghcr.io/home-assistant/base:latest

COPY --from=source /hass-backup /usr/bin/hass-backup
COPY --chmod=755 run.sh /run.sh

CMD [ "/run.sh" ]
