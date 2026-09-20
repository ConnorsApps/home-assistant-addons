# The app is the published frigate-notifications binary dropped into the Home
# Assistant base image, which brings s6-overlay and bashio for reading the app's
# options and the MQTT service. Bump SOURCE_VERSION together with `version` in
# config.yaml when taking a new frigate-notifications release.
ARG SOURCE_VERSION=0.1.0

FROM ghcr.io/connorsapps/frigate-notifications:${SOURCE_VERSION} AS source

FROM ghcr.io/home-assistant/base:latest

ARG SOURCE_VERSION
ENV VERSION=${SOURCE_VERSION}

COPY --from=source /app /usr/bin/frigate-notifications
COPY config.example.yaml /usr/share/frigate-notifications/config.example.yaml
COPY --chmod=755 run.sh /run.sh

CMD [ "/run.sh" ]
