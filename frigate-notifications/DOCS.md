# Frigate Notifications

Subscribes to Frigate's MQTT review stream, decides what to send with an ordered rule list, and delivers to named recipients on Home Assistant mobile apps, Slack, ntfy, and Discord. It is the [frigate-notifications](https://github.com/ConnorsApps/frigate-notifications) project; that repository documents rules, lifecycle, presets, and backends in full.

## Setup

1. Install and start the app. The first start finds no configuration, writes an example, and stops with a message.
2. Edit `config.yaml` in the app's config folder, `/addon_configs/<repository>_frigate_notifications/`, reachable with the Samba, SSH, or Studio Code Server add-ons. Set your recipients, cameras, and rules. The schema line at the top gives validation in editors that support it.
3. Start the app again. Check the log: a bad rule is reported by name and stops startup.

Home Assistant is reached through the Supervisor, and the MQTT broker (Mosquitto) is picked up automatically, so neither belongs in `config.yaml`. To use another broker, add an `mqtt:` block there (`broker`, `username`, `password`, and `topicPrefix` if Frigate isn't using `frigate`).

Each `hass` target's `service` is the part after `notify.` (`mobile_app_alice_phone`), and rule conditions such as `entityState` and the solar `hours` read Home Assistant state.

## Options

Everything here is optional, and a value set here wins over the same setting in `config.yaml`. Use them to keep secrets out of the file.

| Option | Description |
|---|---|
| `frigate_url` | Where the app reaches Frigate's unauthenticated API (port 5000), e.g. `http://<frigate app hostname>:5000` for the Frigate app (its hostname is on the app's Info page, or use your Frigate server's address). Media needs this, `public_base_url`, and the signing key. |
| `public_base_url` | The address phones use to reach this app's port 8081, e.g. `https://frigate-notifications.example.com`. |
| `media_signing_key` | Hex string of 32 or more characters that signs media links. Left empty, a key is generated on first start and kept. Changing it invalidates links already sent. |
| `slack_bot_token` | Slack bot token (`xoxb-...`) with `chat:write`. |
| `ntfy_url`, `ntfy_token` | ntfy server (2.16 or newer to update notifications in place) and optional access token. |
| `db_url` | `postgres://` or `mongodb://` URL for the audit log of events and notifications. |
| `redis_url` | `redis://` URL that keeps cooldowns and per-review state across restarts. |

## Media from outside your network

Phones away from home can't reach Frigate, so notifications link to this app's signed media proxy on port **8081**, which fetches from Frigate for them. Home Assistant's ingress can't serve these links because it requires a Home Assistant login, so the port has to be reachable directly: put your reverse proxy or tunnel in front of `<home assistant host>:8081` and set `public_base_url` to its address. Only signed, expiring links are served (24 hours by default; `media.linkTTL` in `config.yaml`).

Without `frigate_url` and `public_base_url` notifications are text only.

## Restarts

With no `redis_url` or `db_url`, cooldowns and per-review state are held in memory and reset when the app restarts, so an alert can repeat right after an update. Set `redis_url` (or `db_url`) to keep them.
