
# Data Migration Guide

This guide outlines the process for migrating data from an existing Forgejo instance to your new Forgejo instance deployed on Render.com.

## Overview
Data migration typically involves two main components:
1.  **Database**: User data, repository metadata, issues, pull requests, etc.
2.  **File System Data**: Git repositories, LFS objects, attachments, avatars.

## Prerequisites
-   Access to your source Forgejo instance (server access for file system, database access).
-   `pg_dump` and `pg_restore` tools installed on your local machine or a machine with database access.
-   `tar` and `scp` (or similar) for transferring files.

## Step 1: Backup Your Source Forgejo Instance

### 1.1 Backup Database
Connect to your source Forgejo database and create a dump. Replace `your_source_db_name`, `your_source_db_user`, and `your_source_db_host` with your actual details.

```bash
pg_dump -h your_source_db_host -U your_source_db_user -Fc your_source_db_name > forgejo_backup.sql
```

### 1.2 Backup File System Data
Identify the data directories of your source Forgejo instance. Common paths are `/var/lib/forgejo` or `/data/forgejo` and `/data/git`.

```bash
# Example for Forgejo data (attachments, avatars, etc.)
tar -czf forgejo_data.tar.gz /path/to/your/forgejo/data_dir

# Example for Git repositories and LFS objects
tar -czf git_data.tar.gz /path/to/your/git/data_dir
```

**Note**: Ensure you capture the `repositories` and `lfs` subdirectories within your Git data directory, and `attachments`, `avatars`, `sessions` (optional) within your Forgejo data directory.

## Step 2: Transfer Backups to a Temporary Location
Transfer the `forgejo_backup.sql`, `forgejo_data.tar.gz`, and `git_data.tar.gz` files to a location accessible by your Render.com environment or a temporary storage service (e.g., S3, Google Cloud Storage).

For example, if you have SSH access to a temporary server:
```bash
scp forgejo_backup.sql user@temp_server:/tmp/
scp forgejo_data.tar.gz user@temp_server:/tmp/
scp git_data.tar.gz user@temp_server:/tmp/
```

## Step 3: Restore Database on Render.com

1.  **Get Render.com Database Credentials**: From your Render.com dashboard, go to your Forgejo database and find the connection details (Host, Port, User, Password, Database Name).
2.  **Restore**: Use `pg_restore` to import your `forgejo_backup.sql` into the Render.com database. You might need to install `postgresql-client` on your local machine.

    ```bash
    PGPASSWORD="<your-render-db-password>" pg_restore -h <your-render-db-host> -p <your-render-db-port> -U <your-render-db-user> -d <your-render-db-name> --clean --no-owner --no-privileges forgejo_backup.sql
    ```
    **Important**: The `--clean` flag will drop existing objects before recreating them, which is useful for a fresh import. `--no-owner` and `--no-privileges` are important to avoid permission issues when restoring to a different PostgreSQL instance.

## Step 4: Restore File System Data on Render.com

This step requires you to access the running Forgejo container on Render.com. You can do this via Render's Shell feature or by temporarily modifying your `Dockerfile` to include `ssh` and then `exec` into the container.

1.  **Access the Container Shell**: In your Render.com dashboard, navigate to your Forgejo web service and click on the "Shell" tab. This will give you a terminal inside your running container.

2.  **Transfer Data to Container**: If your backup files are on a temporary server or cloud storage, you'll need to transfer them into the Render.com container. For example, using `wget` or `curl` if they are publicly accessible, or `scp` if you set up SSH access.

    ```bash
    # Example: if your files are on a public URL
wget https://your-temp-storage.com/forgejo_data.tar.gz -O /tmp/forgejo_data.tar.gz
wget https://your-temp-storage.com/git_data.tar.gz -O /tmp/git_data.tar.gz
    ```

3.  **Extract Data**: Once inside the container, extract the tarballs to the correct locations. The `setup.sh` script creates `/data/forgejo` and `/data/git` as the main data directories.

    ```bash
    # Navigate to the root of the persistent disk
    cd /data

    # Extract Forgejo data
tar -xzvf /tmp/forgejo_data.tar.gz --strip-components=1 -C /data/forgejo

    # Extract Git data
tar -xzvf /tmp/git_data.tar.gz --strip-components=1 -C /data/git
    ```
    **Note**: `--strip-components=1` is crucial if your tarball contains a top-level directory (e.g., `forgejo_data/attachments`). Adjust if your tarball structure is different.

4.  **Run `migrate.sh` (Optional but Recommended)**: The `scripts/migrate.sh` script is designed to help with this process, but it assumes the source backup is already within the container's filesystem. You can adapt it or manually copy files as shown above.

    If you copied your backup to `/tmp/backup_data` inside the container, you could run:
    ```bash
    /usr/local/bin/migrate.sh /tmp/backup_data
    ```
    However, manual extraction as shown above is often more direct after transferring the tarballs.

5.  **Set Permissions**: Ensure correct permissions after extraction.

    ```bash
    chown -R git:git /data/forgejo /data/git
    chmod -R 750 /data/forgejo /data/git
    ```

## Step 5: Restart Forgejo Service
After restoring both the database and file system data, restart your Forgejo web service on Render.com. This will ensure that Forgejo picks up the new data.

## Troubleshooting
-   **Permission Denied**: Double-check `chown` and `chmod` commands. Ensure the `git` user owns the `/data` directory and its contents.
-   **Database Connection Issues**: Verify environment variables for database connection. Check Render.com database logs.
-   **Forgejo Not Starting**: Check the Forgejo service logs on Render.com for specific error messages.
-   **Missing Repositories/Data**: Ensure your `tar` commands correctly captured all necessary subdirectories and that extraction paths are correct.

