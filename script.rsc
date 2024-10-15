/system script
add name=export-and-send-config-to-server policy=ftp,read,write,test source="/export file=config show-sensitive;\
    \r\
    \n/tool fetch upload=yes url=sftp://{{SFTP_SERVER_ADDRESS}}/{{REMOTE_PATH}}/{{REMOTE_FILENAME}} src-path={{CONFIG_FILENAME}} user={{SFTP_USERNAME}} password={{SFTP_PASSWORD}}"