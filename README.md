# MikroTik Configuration Backup Using Git

MikroTik does not natively support Git, but you can push configuration backups to a remote server where they are automatically committed and pushed to a Git repository.

This guide will help you set up a system for backing up MikroTik configurations using Git. This lets you track and revert changes easily.

### Prerequisites

1. A remote server with [PKI Authentication Enabled](mikrotik-pki-auth.md) and a Git repository.
2. Scheduler on your MikroTik to automate backups.

## Set Up a Scheduler

Create a scheduler to run the backup daily:

```mikrotik
/system scheduler add interval=1d name=config-daily-backup on-event="config-daily-backup-script"
```

## Create the Config Backup Script

Configure Git on your remote server, then replace `SFTP_SERVER_ADDRESS`, `SFTP_USERNAME`, and `REMOTE_PATH` with your details:

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
:do {/system ssh-exec address=$sftpAddr user=$sftpUser command=("cd " . $sftpDirectory . "; git add " . $config . ".rsc; git commit -m \"config backup for " . [/system identity get name] . "\"; git push")} on-error={/log error "Git operations failed"}
```

## Git Configuration

On your remote server, install and configure Git if not already done. Create and initialize a Git repository in the desired directory

```bash
mkdir REMOTE_PATH
cd REMOTE_PATH
git init

```
