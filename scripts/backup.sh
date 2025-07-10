
#!/bin/bash

# Backup script for Forgejo on Render.com
set -e

BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 Creating backup in $BACKUP_DIR..."

# Backup database
echo "🗄️ Backing up database..."
pg_dump "$DATABASE_URL" > "$BACKUP_DIR/database.sql"

# Backup data directories
echo "📁 Backing up data directories..."
tar -czf "$BACKUP_DIR/forgejo_data.tar.gz" -C /data forgejo/
tar -czf "$BACKUP_DIR/git_data.tar.gz" -C /data git/

# Create backup manifest
echo "📋 Creating backup manifest..."
cat > "$BACKUP_DIR/manifest.txt" << EOF
Forgejo Backup
Created: $(date)
Database: Included (database.sql)
Forgejo Data: Included (forgejo_data.tar.gz)
Git Data: Included (git_data.tar.gz)
EOF

echo "✅ Backup completed: $BACKUP_DIR"

