# ConnorsApps Home Assistant Apps

[![Add this repository to your Home Assistant instance.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FConnorsApps%2Fhome-assistant-addons)

Apps (add-ons) for Home Assistant OS and Supervised installations. Home Assistant Container and Core installs have no Supervisor and can't run them; use the projects' Docker images and Helm charts directly.

| App | What it does | Source |
|---|---|---|
| [Frigate Notifications](frigate-notifications/DOCS.md) | Rule-based Frigate notifications to phones through Home Assistant, Slack, ntfy, and Discord, with signed media links that work off the home network | [frigate-notifications](https://github.com/ConnorsApps/frigate-notifications) |
| [Home Assistant Backup](hass-backup/DOCS.md) | Scheduled Home Assistant backups to S3-compatible storage, Google Cloud Storage, or a local folder, with retention | [home-assistant-backup](https://github.com/ConnorsApps/home-assistant-backup) |

## Install

1. In Home Assistant open **Settings → Apps**, select **Install app**, then **⋮ → Repositories**.
2. Add `https://github.com/ConnorsApps/home-assistant-addons` (or use the button above).
3. Install an app from the **ConnorsApps Home Assistant Apps** section and read its **Documentation** tab.

Older Home Assistant versions call these add-ons and the store the add-on store.

## How this repository works

Each directory is an app. Its Docker image is the upstream project's published binary in the Home Assistant base image (for the options form, the Supervisor API, and MQTT discovery), so the apps behave exactly like the standalone projects. `run.sh` turns the app's options and what the Supervisor knows into the environment those projects read.

`version` in an app's `config.yaml` is the tag of its image, `ghcr.io/connorsapps/ha-addon-<slug>`. To take a new upstream release, bump `SOURCE_VERSION` in the app's `Dockerfile` and `version` in its `config.yaml` together; merging to `main` publishes the multi-arch image (`amd64`, `aarch64`). A version that already exists is never republished.

## Developing

Build an app's image from the upstream release it pins:

```sh
docker build -t ha-addon-hass-backup hass-backup
```

To try an app on a real Home Assistant, copy its directory into the `addons` share (`/addons/local/<slug>`), remove the `image:` line from the copy so the Supervisor builds it locally, and install it from the **Local add-ons** section.
