#!/bin/bash

# Setup script for Forgejo on Render.com
set -e

echo "🚀 Starting Forgejo setup on Render.com..."

# Create necessary directories
mkdir -p /data/forgejo/{conf,data,log,sessions,uploads,avatars,repo-avatars,attachments}
mkdir -p /data/git/{repositories,lfs}

# Process configuration template
echo "📝 Processing configuration template..."
envsubst < /data/forgejo/conf/app.ini.template > /data/forgejo/conf/app.ini

# Set proper permissions
chown -R git:git /data/forgejo /data/git
chmod -R 750 /data/forgejo /data/git

# Wait for database to be ready
echo "🔍 Waiting for database connection..."
until pg_isready -h "$DB_HOST" -p 5432 -U "$DB_USER" -d "$DB_NAME"; do
    echo "Database not ready, waiting..."
    sleep 5
done

echo "✅ Database connection established!"

# Initialize Forgejo if needed
if [ ! -f /data/forgejo/conf/app.ini.lock ]; then
    echo "🔧 Initializing Forgejo..."
    
    # Create initial admin user if environment variables are set
    if [ -n "$ADMIN_USERNAME" ] && [ -n "$ADMIN_PASSWORD" ] && [ -n "$ADMIN_EMAIL" ]; then
        forgejo migrate
        forgejo admin user create --admin --username "$ADMIN_USERNAME" --password "$ADMIN_PASSWORD" --email "$ADMIN_EMAIL"
    fi
    
    touch /data/forgejo/conf/app.ini.lock
fi

echo "🎉 Setup complete! Starting Forgejo..."

# Start Forgejo
exec forgejo web --config /data/forgejo/conf/app.ini

