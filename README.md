# Using Git for MikroTik Configuration Backup

MikroTik does not natively support Git, you can implement a solution by pushing configuration backups to a remote server, where they are automatically committed and pushed to a Git repository.

This guide will help you set up a system for backing up MikroTik configurations using Git. By doing so, you can maintain version control, track and revert configuration changes, and document these changes over time.

## Prerequisites

Create a new scheduler to run the backup script. Set your desired `interval` according to your setup. For more information, refer to the [Scheduler Documentation](https://help.mikrotik.com/docs/display/ROS/Scheduler).

```mikrotik
/system scheduler add interval=1d name=config-daily-backup
```

You can now either create a new script or set the On Event field in the scheduler to perform the backup.

Use the following script to export the device configuration and push it to the remote server. Make sure to modify the parameters according to your setup:

| Parameters            | Description                                                                             |
| --------------------- | --------------------------------------------------------------------------------------- |
| `SFTP_SERVER_ADDRESS` | The address of your remote SFTP server                                                  |
| `SFTP_USERNAME`       | The username for your remote SFTP server                                                |
| `REMOTE_PATH`         | The path to the directory where the configuration should be stored on the remote server |

```mikrotik
:local config ("config_" . [/system identity get name])
:do {/export file=$config show-sensitive} on-error={/log error "Configuration export failed"}
:local sftpAddr "SFTP_SERVER_ADDRESS"
:local sftpUser "SFTP_USERNAME"
:local sftpDirectory "REMOTE_PATH"
:local sftpUrl ("sftp://" . $sftpAddr . ":" . $sftpDirectory . "/")
:do {
/tool fetch url=($sftpUrl . $config . ".rsc") src-path=($config . ".rsc") user=$sftpUser upload=yes;
:delay 5s;
/file remove ($config . ".rsc")
} on-error={/log error "File upload failed"}
:do {/system ssh-exec address=$sftpAddr user=$sftpUser command=("cd " . $sftpDirectory . "; git add " . $config . ".rsc; git commit -m \"" . [/system identity get name] . "\"; git push")} on-error={/log error "Git operations failed"}
```
