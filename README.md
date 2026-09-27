# ConnorsApps Home Assistant Apps

[![Add this repository to your Home Assistant instance.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FConnorsApps%2Fhome-assistant-addons)

Apps for Home Assistant OS and Supervised.

| App | |
|---|---|
| [Frigate Notifications](frigate-notifications/DOCS.md) | Rule-based Frigate notifications via Home Assistant, Slack, ntfy, and Discord |
| [Home Assistant Backup](hass-backup/DOCS.md) | Scheduled backups to S3, GCS, or a local folder |

## Install

**Settings → Apps → Install app → ⋮ → Repositories**, then add `https://github.com/ConnorsApps/home-assistant-addons`.

## Maintaining

Each app is an upstream binary (`SOURCE_VERSION` in its Dockerfile) in the Home Assistant base image; `run.sh` maps options to env. `version` in `config.yaml` is the tag of `ghcr.io/connorsapps/ha-addon-<slug>`; merging to `main` publishes each version once, so bump it with any change.

Upstream releases are picked up by the Update workflow: daily, from **Run workflow**, or right away when frigate-notifications or home-assistant-backup tags a release. It bumps `SOURCE_VERSION`, `version` and the changelog, builds, commits to `main` and runs Publish. Run on another branch, it only prints the change.

To test on a real instance, copy an app to `/addons/local/<slug>` without its `image:` line.
