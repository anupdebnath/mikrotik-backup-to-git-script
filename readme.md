# Using Git for MikroTik Configuration Backup

Using Git for MikroTik configuration backup can help you maintain version control over configuration changes and provide a simple way to track, revert, and document these changes over time. While MikroTik does not natively support Git, you can implement a solution using a combination of MikroTik's scripting. You will need a remote Server for this automation.

## Configure MikroTik to Push Configurations to the Server

Change following parameters

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
policy=ftp,read,write,policy \
source="/export file=config show-sensitive;\
    \r\
    \n/tool fetch url=sftp://{{SFTP_SERVER_ADDRESS}} mode=sftp user={{SFTP_USERNAME}} password={{SFTP_PASSWORD}} src-path={{CONFIG_FILENAME}} dst-path={{REMOTE_PATH}}/{{REMOTE_FILENAME}} upload=yes"
```

Then create a scheduler using following

```
/system scheduler
add interval=1d name=daily-config-backup \
    on-event=export-and-send-config-to-server \
    policy=ftp,read,write,policy \
    start-date=2024-10-14 \
    start-time=00:00:00
```

## Set Up a Remote Server for Automation

I recommend you to creat a new user on your remote server with limited privileges. This user should only have access to the repository.

## Automate Git Commit and Push on the Remote Server

Create a script on your remote server that will automate the commit and push process. This script should periodically pull the latest configuration from the MikroTik device and commit it to the repository.

```

# Add the file to Git
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

Schedule the Script to Run
Schedule the Git commit and push script using cron. Open the crontab editor:

bash

```
crontab -e
```

Add the following line to run the script daily:

```
0 2 * * * /path/to/backup-config-to-git.sh
```

This will commit the MikroTik configuration to Git every day at 2 AM.
