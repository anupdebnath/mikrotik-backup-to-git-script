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