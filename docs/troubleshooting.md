
# Troubleshooting Guide

This guide provides solutions to common issues you might encounter when deploying or running Forgejo on Render.com.

## Common Issues and Solutions

### 1. Forgejo Service Fails to Start

**Symptom**: The Render.com service logs show errors during startup, and the service status is 


unhealthy.

**Possible Causes & Solutions**:
-   **Database Connection Issues**: 
    -   **Check Logs**: Look for messages like `pq: password authentication failed` or `connection refused`. This indicates issues with `DB_HOST`, `DB_NAME`, `DB_USER`, or `DB_PASSWD` environment variables.
    -   **Verify Credentials**: Ensure the database credentials in your Render.com environment variables exactly match those of your Render.com PostgreSQL database.
    -   **Database Not Ready**: The `setup.sh` script includes a wait loop for the database. If it times out, check if your database service is running and accessible.
-   **Incorrect `app.ini` Configuration**: 
    -   The `setup.sh` script generates `app.ini` from `app.ini.template` using `envsubst`. If environment variables are missing or malformed, the resulting `app.ini` might be invalid.
    -   **Inspect `app.ini`**: You can shell into the running container (if it manages to start) or temporarily modify the `Dockerfile` to inspect `/data/forgejo/conf/app.ini` after the `setup.sh` runs.
-   **Permissions Issues**: 
    -   Forgejo requires specific permissions for its data directories (`/data/forgejo`, `/data/git`). The `setup.sh` script attempts to set these (`chown -R git:git`, `chmod -R 750`).
    -   **Verify Permissions**: If the service fails with permission errors, shell into the container and manually check permissions using `ls -la /data`.
-   **Disk Space**: 
    -   If your persistent disk is full, Forgejo might fail to start or operate correctly.
    -   **Check Disk Usage**: In Render.com dashboard, check the disk usage for your Forgejo service.

### 2. Git Operations (Clone/Push) Fail via SSH

**Symptom**: You can access the Forgejo web UI, but `git clone` or `git push` via SSH fails.

**Possible Causes & Solutions**:
-   **SSH Domain Mismatch**: 
    -   Ensure `SSH_DOMAIN` environment variable in Render.com matches the actual SSH URL provided by Forgejo (e.g., `ssh://git@your-service.onrender.com:22/user/repo.git`).
    -   The `app.ini.template` uses `SSH_DOMAIN` for the `[server] SSH_DOMAIN` setting.
-   **SSH Key Issues**: 
    -   Ensure your SSH public key is correctly added to your Forgejo user profile.
    -   Verify your local SSH agent is running and has the correct private key loaded (`ssh-add -l`).
-   **Firewall/Port Issues**: 
    -   Render.com handles port exposure. Ensure Forgejo is listening on port 22 for SSH (which it does by default in the Dockerfile and `app.ini.template`).

### 3. Git Operations Fail via HTTPS

**Symptom**: You can access the Forgejo web UI, but `git clone` or `git push` via HTTPS fails.

**Possible Causes & Solutions**:
-   **`ROOT_URL` Mismatch**: 
    -   Ensure `ROOT_URL` environment variable in Render.com matches the actual HTTPS URL of your Forgejo instance (e.g., `https://your-service.onrender.com/`).
    -   The `app.ini.template` uses `ROOT_URL` for the `[server] ROOT_URL` setting.
-   **SSL/TLS Issues**: 
    -   Render.com automatically provides SSL certificates. If you are using a custom domain, ensure your DNS records and SSL settings are correctly configured on Render.com.

### 4. Data Not Persistent After Restart

**Symptom**: After restarting the Forgejo service, all your repositories, users, and data are gone.

**Possible Causes & Solutions**:
-   **Persistent Disk Not Mounted Correctly**: 
    -   In `render.yaml`, ensure the `disk` section is correctly configured with a `mountPath` of `/data`.
    -   The `Dockerfile` and `setup.sh` are designed to use `/data` for all persistent data (`/data/forgejo`, `/data/git`). If this mount fails, data will be written to the ephemeral container filesystem.
    -   **Check Render.com Dashboard**: Verify that the persistent disk is attached and healthy in your Render.com service settings.

### 5. Slow Performance

**Symptom**: Forgejo UI is slow, or Git operations take a long time.

**Possible Causes & Solutions**:
-   **Insufficient Resources**: 
    -   Your Render.com plan might not have enough CPU or RAM for your workload.
    -   **Upgrade Plan**: Consider upgrading your Render.com web service and database plans to a higher tier (e.g., `Standard` or `Pro`).
-   **Database Performance**: 
    -   Slow database queries can impact overall performance.
    -   **Monitor Database**: Use Render.com's database metrics to identify slow queries or high resource usage.
-   **Disk I/O**: 
    -   Frequent Git operations can be I/O intensive. If your disk is slow, it will affect performance.
    -   **Disk Type**: Render.com uses SSDs, but heavy I/O can still be a bottleneck. Upgrading your disk size might sometimes improve I/O performance.

### 6. Admin User Not Created on First Run

**Symptom**: You set `ADMIN_USERNAME`, `ADMIN_PASSWORD`, `ADMIN_EMAIL` environment variables, but no admin user is created.

**Possible Causes & Solutions**:
-   **`app.ini.lock` Exists**: 
    -   The `setup.sh` script only attempts to create the admin user if `/data/forgejo/conf/app.ini.lock` does not exist. If this file was created during a previous (possibly failed) run, the admin user creation step will be skipped.
    -   **Delete Lock File**: If you want to force admin user creation, you can shell into the container and delete `/data/forgejo/conf/app.ini.lock` (be cautious, this might trigger other re-initialization steps).
-   **Environment Variables Not Set**: 
    -   Double-check that all three `ADMIN_USERNAME`, `ADMIN_PASSWORD`, and `ADMIN_EMAIL` variables are correctly set in Render.com.

## Getting Further Help

If you've exhausted the troubleshooting steps above:

1.  **Check Render.com Logs**: The most valuable source of information is always the service logs in your Render.com dashboard.
2.  **Forgejo Documentation**: Refer to the official Forgejo documentation for detailed configuration options and common issues.
3.  **Render.com Support**: For platform-specific issues (e.g., disk problems, network issues), contact Render.com support.
4.  **Community Forums**: Search or ask for help in Forgejo or Render.com community forums.

