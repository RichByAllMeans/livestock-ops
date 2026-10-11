# Runbook: Schema migration

Migrations live in **livestock-db** and are the only way schema changes ship.
No ad-hoc DDL against any environment.

## Local

```bash
cd ../livestock-infra
make migrate-up
make seed
```

## Review checklist (PR to livestock-db)

- [ ] Has a `-- migrate:down` that actually reverses the change.
- [ ] New columns are nullable or have defaults (no breaking `NOT NULL` on big tables).
- [ ] New indexes created `CONCURRENTLY` on large tables (outside a transaction).
- [ ] `tenant_id` present and indexed on every new business table.
- [ ] Append-only tables are not given `updated_at`/UPDATE triggers.

## Production

1. Take a fresh backup (`scripts/backup.sh`).
2. Announce a change window in the team channel.
3. Apply with `dbmate up` against the maintenance connection.
4. Run `scripts/healthcheck.sh`; watch error rates for 10 minutes.
5. If a rollback is needed, `dbmate down` **only** for additive migrations;
   destructive changes require a restore, not a down-migration.
