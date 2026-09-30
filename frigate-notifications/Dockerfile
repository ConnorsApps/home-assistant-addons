# Bump SOURCE_VERSION with `version` in config.yaml.
ARG SOURCE_VERSION=0.2.0

FROM ghcr.io/connorsapps/frigate-notifications:${SOURCE_VERSION} AS source

FROM ghcr.io/home-assistant/base:latest

ARG SOURCE_VERSION
ENV VERSION=${SOURCE_VERSION}

COPY --from=source /app /usr/bin/frigate-notifications
COPY config.example.yaml /usr/share/frigate-notifications/config.example.yaml
COPY --chmod=755 run.sh /run.sh

CMD [ "/run.sh" ]
