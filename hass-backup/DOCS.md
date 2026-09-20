# Home Assistant Backup

Creates a full Home Assistant backup on a schedule, uploads it to storage you control, then deletes it from Home Assistant so the copies don't pile up on the same disk. Older uploads beyond the retention count are removed from storage.

The app asks the Supervisor for the backup, so it needs no access token. It is the [home-assistant-backup](https://github.com/ConnorsApps/home-assistant-backup) project; that repository documents the same settings for running it outside Home Assistant.

## Options

| Option | Default | Description |
|---|---|---|
| `schedule` | `0 3 * * *` | When to back up: a standard 5-field cron expression in Home Assistant's time zone (`@daily` works too). Empty runs one backup each time the app starts, then stops. |
| `storage_url` | `file:///share/hass-backups` | Where to upload. `file:///share/...` is the Home Assistant `share` folder (created if missing), `s3://bucket`, or `gs://bucket`. |
| `storage_prefix` | `home-assistant/` | Prefix on every uploaded file. Retention only counts files under it. |
| `retention_keep_last` | `30` | Keep this many uploads and delete older ones. `0` keeps everything. |
| `delete_after_transfer` | on | Remove the backup from Home Assistant once it is uploaded. |
| `timeout` | `30m` | Time limit for creating the backup, and separately for downloading and uploading it (`30m`, `1h30m`). Raise it for a large installation or a slow uplink. |
| `log_level` | `info` | `debug`, `info`, `warn`, or `error`. |

Uploaded files are named `<prefix><UTC timestamp>-<slug>.tar`.

### S3-compatible storage

Set `storage_url` to `s3://my-bucket` and fill in the access key options. For MinIO, Ceph, Backblaze B2 and similar, also set `aws_endpoint_url`, `aws_region`, and append `?use_path_style=true` to the URL (without it the AWS SDK addresses `<bucket>.<endpoint>`, which usually doesn't resolve):

```yaml
storage_url: s3://my-bucket?use_path_style=true
aws_endpoint_url: https://minio.example.com
aws_region: us-east-1
aws_access_key_id: ...
aws_secret_access_key: ...
```

### Google Cloud Storage

Set `storage_url` to `gs://my-bucket`, put a service account key JSON in the app's config folder (`/addon_configs/<repository>_hass_backup/gcs.json`, reachable over Samba or the SSH add-on), and set `google_credentials_file` to `gcs.json`. The service account needs to create and delete objects in the bucket.

## Notes

- Backups run one at a time, and a failed run (Home Assistant restarting, storage unreachable) is logged and retried at the next tick, not fatal.
- If a run fails after Home Assistant has made the backup (the upload failed, say), the backup is left in Home Assistant, since it may be the only copy. The log names its slug. Repeated failures leave one each; delete them under **Settings → System → Backups** once the cause is fixed.
- Home Assistant may take its own automatic backups too. This app only deletes the backups it creates.
