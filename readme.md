# Using Git for MikroTik Configuration Backup

This guide helps you set up a solution for backing up MikroTik configurations using Git. By integrating MikroTik's scripting capabilities with Git, you can maintain version control over configuration changes, track, revert, and document these changes over time.

While MikroTik does not natively support Git, we can implement this solution by pushing configuration backups to a remote server, where they are automatically committed and pushed to a Git repository.

## Step 1: Configure MikroTik to Push Configurations to the Remote Server

Create a MikroTik script that exports the device configuration and pushes it to the remote server via SFTP. You'll need to change the following parameters according to your setup:

| Parameters            | Description                                                                         |
| --------------------- | ----------------------------------------------------------------------------------- |
| `SFTP_SERVER_ADDRESS` | Address of your remote SFTP server                                                  |
| `SFTP_USERNAME`       | Username for your remote SFTP server                                                |
| `SFTP_PASSWORD`       | Password for your remote SFTP server                                                |
| `CONFIG_FILENAME`     | Name of the file containing the configuration on the MikroTik device                |
| `REMOTE_PATH`         | Path to the directory where the configuration should be stored on the remote server |
| `REMOTE_FILENAME`     | Name of the file containing the configuration on the remote server                  |

```
/system script
add name=export-and-send-config-to-server \
policy=ftp,read,write,test \
source="/export file=config show-sensitive;\
    \r\
    \n/tool fetch upload=yes url=sftp://{{SFTP_SERVER_ADDRESS}}/{{REMOTE_PATH}}/{{REMOTE_FILENAME}} src-path={{CONFIG_FILENAME}} user={{SFTP_USERNAME}} password={{SFTP_PASSWORD}}"
```

Schedule the Script to Run Daily. You can also change the `interval` according to your setup. [Scheduler Documentation](https://help.mikrotik.com/docs/display/ROS/Scheduler)

```
/system scheduler
add interval=1d name=daily-config-backup \
    on-event=export-and-send-config-to-server \
    policy=ftp,read,write,test \
    start-date=2024-10-14 \
    start-time=00:00:00
```

## Step 2: Set Up a Remote Server for Automation (Optional)

On the remote server, create a new user with limited privileges. This user should have access only to the Git repository directory where the backups will be stored.

## Step 3: Automate Git Commit and Push on the Remote Server

Next, set up a script on the remote server to automatically commit and push the configuration files to a Git repository.

Create a script on the remote server (e.g. `backup-config-to-git.sh`) that will automate the Git commit and push process.

```
#!/bin/bash

# Set up the git repository path
REPO_PATH="/path/to/your/repo"

# Navigate to the repository
cd $REPO_PATH

# Add config file to git
git add config.rsc

# Commit the changes with a timestamp
git commit -m "Backup config at $(date)"

# Push the changes to the remote repository
git push
```

Make the script executable:

```
chmod +x backup-config-to-git.sh
```

### Schedule the Script to Run Daily

Use cron to schedule the backup script. Open the crontab editor:

```
crontab -e
```

Add the following line to run the script every day at 2 AM:

```
0 2 * * * /path/to/backup-config-to-git.sh
```
