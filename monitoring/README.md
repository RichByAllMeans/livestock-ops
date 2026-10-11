# Monitoring

Use `postgres_exporter` with Prometheus/Grafana. Point it at the pooled or
direct DSN and scrape `/metrics`.

## Alert-worthy queries

```sql
-- Connections near max
SELECT count(*) FROM pg_stat_activity;

-- Long-running queries (> 5 min)
SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state <> 'idle' AND now() - query_start > interval '5 minutes';

-- Cache hit ratio (want > 0.99)
SELECT sum(blks_hit) / nullif(sum(blks_hit) + sum(blks_read), 0) AS hit_ratio
FROM pg_stat_database;

-- Table bloat / dead tuples worth vacuuming
SELECT relname, n_dead_tup, last_vacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC LIMIT 10;
```

## Business-level signals

```sql
SELECT count(*) FROM stock_alerts WHERE NOT is_resolved;            -- open alerts
SELECT count(*) FROM notifications WHERE status = 'pending'
  AND scheduled_at < now();                                          -- stuck sends
```

## Suggested alert thresholds

| Signal                 | Warn            | Critical        |
|------------------------|-----------------|-----------------|
| connections            | > 80% of max    | > 95%           |
| cache hit ratio        | < 0.98          | < 0.95          |
| replication lag (PITR) | > 30s           | > 5 min         |
| disk usage (pgdata)    | > 75%           | > 90%           |
