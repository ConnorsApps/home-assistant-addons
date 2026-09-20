# Frigate Notifications

Turns Frigate's MQTT review stream into notifications with ordered rules, per-person policy, and delivery via Home Assistant, Slack, ntfy, and Discord. This is [frigate-notifications](https://github.com/ConnorsApps/frigate-notifications), which documents rules and backends.

## Setup

1. Start the app. With no config it writes an example and stops.
2. Edit `config.yaml` in the app's config folder, `/addon_configs/<repository>_frigate_notifications/` (Samba, SSH, or Studio Code Server): recipients, cameras, rules.
3. Start the app. A bad rule is reported by name.

Home Assistant and the MQTT broker (Mosquitto) are configured for you. For another broker, add an `mqtt:` block to `config.yaml`. A `hass` target's `service` is the part after `notify.`.

## Options

All optional. A value here beats the same setting in `config.yaml`.

| Option | |
|---|---|
| `frigate_url` | Frigate's unauthenticated API, e.g. `http://<frigate app hostname>:5000` |
| `public_base_url` | Address phones use to reach port 8081, e.g. `https://frigate-notifications.example.com` |
| `media_signing_key` | Hex, 32+ chars. Empty: generated once and kept. Changing it breaks links already sent. |
| `slack_bot_token` | `xoxb-...` with `chat:write` |
| `ntfy_url`, `ntfy_token` | ntfy server (2.16+ to update in place) and optional token |
| `db_url` | `postgres://` or `mongodb://` audit log |
| `redis_url` | Keeps cooldowns and per-review state across restarts |

## Media off the LAN

Notifications link to a signed proxy on port **8081**, since phones can't reach Frigate directly. Ingress can't serve it (it needs a Home Assistant login), so put a reverse proxy or tunnel in front of `<host>:8081` and set `public_base_url`. Media also needs `frigate_url`; without them notifications are text only.

## Restarts

Without `redis_url` or `db_url`, cooldowns and per-review state reset on restart, so an alert can repeat after an update.
