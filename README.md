# livestock-ops

Operational tooling for the Livestock database: backups, restore, monitoring and
runbooks. Addresses the brief's non-functional requirements (backup/recovery,
downtime handling) and the audit-trail retention policy.

## Layout

```
scripts/    backup.sh, restore.sh, healthcheck.sh
runbooks/   step-by-step procedures (backup/restore, migrations, incidents)
monitoring/ Prometheus queries + postgres_exporter notes
```

## Scripts

All scripts read `DATABASE_URL` from the environment (see `livestock-infra/.env`).

```bash
export DATABASE_URL=postgres://livestock:...@localhost:5432/livestock?sslmode=disable
./scripts/backup.sh ./backups          # logical dump, compressed
./scripts/restore.sh ./backups/<file>  # restore into a target DB
./scripts/healthcheck.sh               # connectivity + key checks
```

> For production, prefer physical backups (pgBackRest/WAL archiving) — see
> `runbooks/backup-restore.md`. These scripts are the simple, portable baseline.
