/system scheduler
add interval=1d name=daily-config-backup on-event=export-and-send-config-to-server policy=\
    ftp,read,write,test start-date=2024-10-14 start-time=00:00:00