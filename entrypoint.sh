#!/bin/sh
echo $ANYCONNECT_PASSWORD | openconnect --background --authgroup $ANYCONNECT_GROUP $ANYCONNECT_SERVER --user=$ANYCONNECT_USER --timestamp
# sleep 10
# echo 'Connected, attempting to mount'
# mount -t cifs --verbose //$CIFS_HOST/$CIFS_PATH /mnt/local_share  -o user=$ANYCONNECT_USER,password=$NYCONNECT_PASSWORD
# echo 'Mounted'