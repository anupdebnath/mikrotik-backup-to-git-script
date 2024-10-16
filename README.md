# Using Git for MikroTik Configuration Backup

Although MikroTik does not natively support Git, you can implement a solution by pushing configuration backups to a remote server, where they are automatically committed and pushed to a Git repository.

This guide will help you set up a system for backing up MikroTik configurations using Git. By doing so, you can maintain version control, track and revert configuration changes, and document these changes over time.

### Step 01: Push Config to the Remote Server

Create a new scheduler to run the backup script. Set your desired `interval` according to your setup. For more information, refer to the [Scheduler Documentation](https://help.mikrotik.com/docs/display/ROS/Scheduler).

```
/system scheduler
add interval=1d name=sftp-daily-backup
```

You can now either create a new script or set the On Event field in the scheduler to perform the backup.

Use the following script to export the device configuration and push it to the remote server via SFTP. Make sure to modify the parameters according to your setup:

| Parameters            | Description                                                                             |
| --------------------- | --------------------------------------------------------------------------------------- |
| `SFTP_SERVER_ADDRESS` | The address of your remote SFTP server                                                  |
| `SFTP_USERNAME`       | The username for your remote SFTP server                                                |
| `SFTP_PASSWORD`       | The password for your remote SFTP server                                                |
| `CONFIG_FILENAME`     | The name of the configuration file on the MikroTik device                               |
| `REMOTE_PATH`         | The path to the directory where the configuration should be stored on the remote server |
| `REMOTE_FILENAME`     | The name of the configuration file on the remote server                                 |

```
# Variables
:local sftpAddr "SFTP_SERVER_ADDRESS"
:local sftpPort "SFTP_SERVER_PORT"
:local sftpUser "SFTP_USERNAME"
:local sftpPass "SFTP_PASSWORD"
:local sftpDirectory "REMOTE_PATH"

### Generate SFTP URL
:local sftpUrl ("sftp://" . $sftpAddr . ":" . $sftpPort . $sftpDirectory . "/")

### Define export file names
:local exportFileName ("config_" . [/system identity get name])



# Generate config export
:do {
/export file=$exportFileName show-sensitive
} on-error={/log error "Export failed: Could not export the configuration!"}



# Upload export to SFTP server
:do {
/tool fetch url=($sftpUrl . $exportFileName . ".rsc") src-path=($exportFileName . ".rsc") user=$sftpUser password=$sftpPass upload=yes
### Remove local backup file
/file remove ($exportFileName . ".rsc")
} on-error={/log error "Config upload failed: Could not upload the configuration!"}
```

## Step 2: Set Up a Remote Server for Automation (Optional)

On the remote server, create a new user with limited privileges. Ensure this user has access only to the directory where the Git repository backups will be stored.

## Step 3: Automate Git Commit and Push on the Remote Server

Next, set up a script on the remote server to automatically commit and push the configuration files to a Git repository. Create a script on the remote server (e.g. `backup-config-to-git.sh`) that will automate the Git commit and push process.

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

### Schedule the Script to automatically

Use cron to schedule the backup script. Open the crontab editor:

```
crontab -e
```

Add the following line to run the script every day at 2 AM:

```
0 2 * * * /path/to/backup-config-to-git.sh
```
