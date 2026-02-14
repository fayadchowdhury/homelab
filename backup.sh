#!/bin/bash

# -----------------------------
# Backup Script for Redis + CNPG
# -----------------------------

# Configuration
BACKUP_DIR="./backups"
REDIS_POD="redis-0"
REDIS_NS="redis"
CNPG_POD="postgres-cluster-1"
CNPG_NS="cnpg-pods"
POSTGRES_USER="postgres"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Timestamp
DATE=$(date +%F-%H%M)

echo "Starting backups: $DATE"
echo "-----------------------"

# -----------------------------
# Redis Backup
# -----------------------------
echo "Backing up Redis..."
kubectl exec -n "$REDIS_NS" "$REDIS_POD" -- redis-cli SAVE

REDIS_FILE="$BACKUP_DIR/redis-dump-$DATE.rdb"
kubectl cp "$REDIS_NS/$REDIS_POD:/data/dump.rdb" "$REDIS_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Redis backup saved to $REDIS_FILE"
else
    echo "❌ Redis backup failed!"
fi

# -----------------------------
# CNPG / Postgres Backup
# -----------------------------
echo "Backing up CNPG (Postgres)..."
CNPG_FILE="$BACKUP_DIR/cnpg-backup-$DATE.sql"

kubectl exec -n "$CNPG_NS" "$CNPG_POD" -- pg_dumpall -U "$POSTGRES_USER" > "$CNPG_FILE"

if [ $? -eq 0 ]; then
    echo "✅ CNPG backup saved to $CNPG_FILE"
else
    echo "❌ CNPG backup failed!"
fi

echo "-----------------------"
echo "All backups complete!"