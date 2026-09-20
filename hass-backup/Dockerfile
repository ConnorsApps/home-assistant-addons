# Bump SOURCE_VERSION with `version` in config.yaml.
ARG SOURCE_VERSION=0.2.0

FROM ghcr.io/connorsapps/home-assistant-backup:${SOURCE_VERSION}-all AS source

FROM ghcr.io/home-assistant/base:latest

COPY --from=source /hass-backup /usr/bin/hass-backup
COPY --chmod=755 run.sh /run.sh

CMD [ "/run.sh" ]
