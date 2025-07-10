# Forgejo Deployment for Render.com

This repository contains everything needed to deploy a Forgejo instance on Render.com, replicating the functionality of the original DotBypasser Git service.

## 🚀 Quick Deploy

1. **Fork this repository** to your GitHub account
2. **Create a Render.com account** and connect your GitHub
3. **Import this repository** in Render.com
4. **Configure environment variables** (see below)
5. **Deploy!**

## 📋 Prerequisites

- Render.com account
- GitHub account (or other Git hosting for your deployment repo)
- Basic knowledge of Git and environment variables

## 🔧 Configuration

### Required Environment Variables

Set these in your Render.com service:

```bash
# Database Configuration (automatically provided by Render.com)
DB_HOST=your-db-host
DB_NAME=your-db-name
DB_USER=your-db-user
DB_PASSWD=your-db-password

# Application Configuration
APP_NAME=DotBypasser Git
RUN_MODE=prod
ROOT_URL=https://your-service.onrender.com
SSH_DOMAIN=your-service.onrender.com

# Security (generate strong random values)
SECRET_KEY=your-secret-key
INTERNAL_TOKEN=your-internal-token
JWT_SECRET=your-jwt-secret

# Optional: Initial Admin User
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your-admin-password
ADMIN_EMAIL=admin@example.com
```

### Render.com Service Configuration

- **Build Command**: `docker build . -t forgejo-app`
- **Start Command**: `/usr/local/bin/setup.sh`
- **Port**: 3000
- **Environment**: Docker
- **Health Check Path**: `/`

## 📊 Features

- ✅ Complete Git hosting service
- ✅ Repository management
- ✅ Issue tracking
- ✅ Pull requests
- ✅ Wiki support
- ✅ Release management
- ✅ User authentication
- ✅ Organization support
- ✅ LFS support
- ✅ Actions/CI support
- ✅ API access
- ✅ SSH access
- ✅ Persistent storage

## 🔄 Data Migration

To migrate from an existing Forgejo instance:

1. **Export database** from source:
   ```bash
   pg_dump source_db > forgejo_backup.sql
   ```

2. **Copy data files** from source server:
   ```bash
   tar -czf forgejo_data.tar.gz /path/to/forgejo/data/
   ```

3. **Import to Render.com**:
   - Upload database using Render.com dashboard
   - Use the migration script: `./scripts/migrate.sh /path/to/backup/`

## 🛠️ Maintenance

### Backup
```bash
./scripts/backup.sh
```

### Update
Rebuild and redeploy through Render.com dashboard

### Monitoring
- Check Render.com service logs
- Monitor database usage
- Watch disk space usage

## 🔐 Security

- All secrets are managed through environment variables
- Database connections use SSL
- HTTPS is enforced by Render.com
- Regular security updates through Docker image updates

## 📱 Scaling

- **Horizontal scaling**: Not recommended for Git services
- **Vertical scaling**: Upgrade Render.com plan as needed
- **Storage scaling**: Increase persistent disk size

## 🆘 Support

For issues:
1. Check Render.com service logs
2. Review Forgejo documentation
3. Check GitHub issues in this repository
4. Contact support if needed

## 📄 License

This deployment configuration is provided under the MIT License.

