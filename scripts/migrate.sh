
#!/bin/bash

# Migration script for existing Forgejo data
set -e

echo "📦 Starting data migration..."

SOURCE_BACKUP_DIR="$1"
TARGET_DATA_DIR="/data"

if [ -z "$SOURCE_BACKUP_DIR" ]; then
    echo "❌ Error: Please provide source backup directory"
    echo "Usage: $0 <source_backup_directory>"
    exit 1
fi

if [ ! -d "$SOURCE_BACKUP_DIR" ]; then
    echo "❌ Error: Source backup directory does not exist"
    exit 1
fi

# Stop Forgejo if running
echo "🛑 Stopping Forgejo service..."
pkill -f "forgejo web" || true

# Backup existing data
echo "💾 Creating backup of existing data..."
mkdir -p /backup/pre-migration
cp -r "$TARGET_DATA_DIR" /backup/pre-migration/

# Migrate repositories
echo "📁 Migrating repositories..."
if [ -d "$SOURCE_BACKUP_DIR/git/repositories" ]; then
    mkdir -p "$TARGET_DATA_DIR/git/repositories"
    cp -r "$SOURCE_BACKUP_DIR/git/repositories/"* "$TARGET_DATA_DIR/git/repositories/"
fi

# Migrate LFS data
echo "📦 Migrating LFS data..."
if [ -d "$SOURCE_BACKUP_DIR/git/lfs" ]; then
    mkdir -p "$TARGET_DATA_DIR/git/lfs"
    cp -r "$SOURCE_BACKUP_DIR/git/lfs/"* "$TARGET_DATA_DIR/git/lfs/"
fi

# Migrate attachments
echo "📎 Migrating attachments..."
if [ -d "$SOURCE_BACKUP_DIR/forgejo/attachments" ]; then
    mkdir -p "$TARGET_DATA_DIR/forgejo/attachments"
    cp -r "$SOURCE_BACKUP_DIR/forgejo/attachments/"* "$TARGET_DATA_DIR/forgejo/attachments/"
fi

# Migrate avatars
echo "🖼️ Migrating avatars..."
if [ -d "$SOURCE_BACKUP_DIR/forgejo/avatars" ]; then
    mkdir -p "$TARGET_DATA_DIR/forgejo/avatars"
    cp -r "$SOURCE_BACKUP_DIR/forgejo/avatars/"* "$TARGET_DATA_DIR/forgejo/avatars/"
fi

# Set proper permissions
echo "🔒 Setting permissions..."
chown -R git:git "$TARGET_DATA_DIR"
chmod -R 750 "$TARGET_DATA_DIR"

echo "✅ Data migration completed!"
echo "📝 Please run database migration separately using pg_dump/pg_restore"

