#!/usr/bin/env bash
# Basic healthcheck: connectivity + row-count sanity + open alerts.
# Usage: DATABASE_URL=... ./scripts/healthcheck.sh
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL is not set}"

q() { psql "$DATABASE_URL" -At -c "$1"; }

echo "== connectivity =="
q "SELECT version();" | head -1

echo "== migration status =="
q "SELECT count(*) FROM schema_migrations;" 2>/dev/null || echo "(dbmate schema_migrations not found)"

echo "== quick counts =="
q "SELECT 'tenants=' || count(*) FROM tenants;"
q "SELECT 'animals=' || count(*) FROM animals;"
q "SELECT 'open_stock_alerts=' || count(*) FROM stock_alerts WHERE NOT is_resolved;"
q "SELECT 'pending_notifications=' || count(*) FROM notifications WHERE status = 'pending';"
