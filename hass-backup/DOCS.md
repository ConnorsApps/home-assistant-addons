# Home Assistant Backup

Makes a full backup on a schedule, uploads it, deletes it from Home Assistant, and prunes old uploads. This is [home-assistant-backup](https://github.com/ConnorsApps/home-assistant-backup); no access token needed.

| Option | Default | |
|---|---|---|
| `schedule` | `0 3 * * *` | Cron, in Home Assistant's time zone. Empty: one backup per app start. |
| `storage_url` | `file:///share/hass-backups` | `file:///share/...` (created if missing), `s3://bucket`, or `gs://bucket` |
| `storage_prefix` | `home-assistant/` | Prefix on uploads; retention counts only these |
| `retention_keep_last` | `30` | Newest uploads to keep; `0` keeps all |
| `delete_after_transfer` | on | Delete from Home Assistant after upload |
| `timeout` | `30m` | Limit for creating, and separately for downloading and uploading |
| `log_level` | `info` | `debug`, `info`, `warn`, `error` |

Uploads are named `<prefix><UTC timestamp>-<slug>.tar`.

## S3

Set the key options. For MinIO, Ceph, B2 and similar, also set the endpoint and region, and add `?use_path_style=true` to the URL:

```yaml
storage_url: s3://my-bucket?use_path_style=true
aws_endpoint_url: https://minio.example.com
aws_region: us-east-1
```

## Google Cloud Storage

Set `storage_url: gs://my-bucket`, put a service account key in the app's config folder (`/addon_configs/<repository>_hass_backup/gcs.json`), and set `google_credentials_file: gcs.json`.

## Failures

A failed run is logged and retried at the next tick. If it fails after the backup is made (say, the upload), the backup stays in Home Assistant, since it may be the only copy. The log names its slug; delete leftovers under **Settings → System → Backups**.
