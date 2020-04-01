#!/bin/sh

#
# Define cleanup procedure
#

cleanup() {
    echo "Container stopped, performing cleanup..."
    echo "Unmounting "
    unmount /mnt/local_share

    echo  "Stopping VPN connection:"
    sudo ps -aef | grep openconnect
    sudo kill -9 $(pidof openconnect)
}


#
# Trap SIGTERM
#

trap 'cleanup' SIGTERM

echo $ANYCONNECT_PASSWORD | openconnect --authgroup $ANYCONNECT_GROUP $ANYCONNECT_SERVER --user=$ANYCONNECT_USER --timestamp &

sleep 15
echo "Preparing to mount CIFS share"
mount -t cifs //$CIFS_HOST/$CIFS_PATH /mnt/local_share  -o user=$ANYCONNECT_USER,password=$NYCONNECT_PASSWORD
echo "Mounted CIFS share"

child_process=$! 
wait "$child_process"


# Cleanup
cleanup