# Backup and Recovery

3-2-1 backup strategy: 3 copies, 2 media types, 1 off-site. Duplicati for encrypted cloud backups plus Restic for local snapshots.

## Services
Duplicati (Web UI), Restic REST Server (local snapshots)

## Quick Start
```bash
cd stacks/backup && docker compose up -d
../../scripts/backup.sh          # Full backup
../../scripts/backup.sh --list   # List backups
../../scripts/backup.sh --restore latest
```

## Backup Targets
local, minio/s3, b2, r2, sftp, restic — set BACKUP_TARGET in .env

## Automation
Daily cron at 2 AM: `0 2 * * * /path/to/scripts/backup.sh`

## Recovery
See docs/disaster-recovery.md for full guide.