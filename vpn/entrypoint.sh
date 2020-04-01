#!/bin/sh

#
# Define cleanup procedure
#

cleanup() {
    echo "Container stopped, performing cleanup..."
    #
    # Checks if we have a mount point on /mnt/local_share
    #
    [[ "$(df -P /mnt/local_share | tail -1 | cut -d' ' -f 1)" == "//$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH" ]] && umount /mnt/local_share || echo "No mount point to clean up"

    echo  "Stopping VPN connection:"
    killall -SIGINT openconnect
    # Remove default gateway route rule when there is already a PPTP connection
	# Uncomment line below if your computer is connected to internet through a PPTP connection
	ip r | grep ppp0 && ip r | grep default | head -n1 | xargs sudo ip r del

    # Send SIGTERM to child/subprocesses
    kill -- -$$
}


#
# Trap SIGTERM and SIGINT and execute 
#
trap cleanup SIGINT SIGTERM
echo $BUILDTIME_ANYCONNECT_PASSWORD | openconnect --authgroup $BUILDTIME_ANYCONNECT_GROUP $BUILDTIME_ANYCONNECT_SERVER --user=$BUILDTIME_ANYCONNECT_USER --timestamp --background

echo "Sleeping 10s. After that will mount the CIFS share"
sleep 10
echo "Preparing to mount CIFS share"
mount -t cifs //$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH /mnt/local_share  -o user=$BUILDTIME_ANYCONNECT_USER,password=$BUILDTIME_ANYCONNECT_PASSWORD
echo "Mounted CIFS share"

#
# Just keep the process alive
#
sleep infinity