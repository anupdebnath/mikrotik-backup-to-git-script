/system script
add name=export-and-send-config-to-server policy=read,write,ftp source="/export file=config show-sensitive;\
    \r\
    \n/tool fetch url=sftp://{{SFTP_SERVER_ADDRESS}} mode=sftp user={{SFTP_USERNAME}} password={{SFTP_PASSWORD}} src-path={{CONFIG_FILENAME}} dst-path={{REMOTE_PATH}}/{{REMOTE_FILENAME}} upload=yes"