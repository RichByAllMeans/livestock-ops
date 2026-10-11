# Runbook: Backup & Restore

## Baseline (logical)

```bash
export DATABASE_URL=postgres://livestock:...@host:5432/livestock?sslmode=disable
./scripts/backup.sh ./backups
```

- Compressed `pg_dump`, keeps last 14 locally.
- Schedule daily via cron/Task Scheduler; ship off-host (S3-compatible).

## Restore

```bash
./scripts/restore.sh ./backups/livestock_YYYYMMDD_HHMMSS.sql.gz
```

Restore into a **fresh** database first, verify with `scripts/healthcheck.sh`,
then cut over. Never restore over the live DB without a current backup.

## Production (physical / PITR)

For zero-data-loss recovery use **pgBackRest** or WAL archiving:

- `archive_mode = on`, `archive_command = 'pgbackrest --stanza=livestock archive-push %p'`
- Take a full backup weekly, differential daily.
- Test a restore monthly into a scratch instance (an untested backup is not a backup).

## Retention

| Type              | Keep        |
|-------------------|-------------|
| Daily logical     | 14 days     |
| Weekly full (PITR)| 8 weeks     |
| Monthly           | 12 months   |

Audit-trail retention is governed by the audit policy in `livestock-db`
(`audit_log` is append-only and not purged without legal sign-off).
