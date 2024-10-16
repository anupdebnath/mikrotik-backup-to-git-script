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