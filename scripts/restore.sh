#!/usr/bin/env bash
# Restore a logical backup produced by backup.sh.
# Usage: DATABASE_URL=... ./scripts/restore.sh ./backups/livestock_*.sql.gz
set -euo pipefail

FILE="${1:?usage: restore.sh <backup.sql.gz>}"
: "${DATABASE_URL:?DATABASE_URL is not set}"

read -r -p "This will overwrite data in the target DB. Continue? [y/N] " ok
[[ "$ok" == "y" || "$ok" == "Y" ]] || { echo "aborted"; exit 1; }

echo ">> restoring $FILE"
gunzip -c "$FILE" | psql "$DATABASE_URL"
echo ">> restore complete"
