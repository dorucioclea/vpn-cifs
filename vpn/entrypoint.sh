#!/bin/sh

#
# Define cleanup procedure
#

cleanup() {
    echo "Container stopped, performing cleanup..."
    echo "Unmounting "
    umount /mnt/local_share

    echo  "Stopping VPN connection:"
    pkill -SIGINT openconnect
    # Remove default gateway route rule when there is already a PPTP connection
	# Uncomment line below if your computer is connected to internet through a PPTP connection
	ip r | grep ppp0 && ip r | grep default | head -n1 | xargs sudo ip r del
}


#
# Trap SIGTERM
#

trap 'cleanup' SIGTERM

echo $BUILDTIME_ANYCONNECT_PASSWORD | openconnect --authgroup $BUILDTIME_ANYCONNECT_GROUP $BUILDTIME_ANYCONNECT_SERVER --user=$BUILDTIME_ANYCONNECT_USER --timestamp &

sleep 15
echo "Preparing to mount CIFS share"
mount -t cifs //$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH /mnt/local_share  -o user=$BUILDTIME_ANYCONNECT_USER,password=$BUILDTIME_NYCONNECT_PASSWORD
echo "Mounted CIFS share"

child_process=$! 
wait "$child_process"


# Cleanup
cleanup