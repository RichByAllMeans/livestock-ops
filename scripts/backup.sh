#!/usr/bin/env bash
# Logical backup of the Livestock database.
# Usage: DATABASE_URL=... ./scripts/backup.sh [output-dir]
set -euo pipefail

OUT_DIR="${1:-./backups}"
STAMP="$(date +%Y%m%d_%H%M%S)"
: "${DATABASE_URL:?DATABASE_URL is not set}"

mkdir -p "$OUT_DIR"
FILE="$OUT_DIR/livestock_${STAMP}.sql.gz"

echo ">> dumping to $FILE"
pg_dump --no-owner --no-privileges "$DATABASE_URL" | gzip -9 > "$FILE"

echo ">> done: $(du -h "$FILE" | cut -f1)"

# Retention: keep the last 14 dumps locally.
ls -1t "$OUT_DIR"/livestock_*.sql.gz 2>/dev/null | tail -n +15 | xargs -r rm -f
