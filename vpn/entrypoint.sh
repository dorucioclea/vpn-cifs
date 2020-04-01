#!/bin/sh

#
# Define cleanup procedure
#

do_exit() {
    echo "Container stopped, performing cleanup..."
    # #
    # # Checks if we have a mount point on /mnt/local_share
    # #
    [[ "$(df -P /mnt/local_share | tail -1 | cut -d' ' -f 1)" == "//$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH" ]] && umount /mnt/local_share || echo "No mount point to clean up"

    echo  "Stopping VPN connection:"
    killall -SIGINT openconnect
    # # Send SIGTERM to child/subprocesses
    kill -- -$$
}

#
# Trap SIGTERM and SIGINT and execute 
#
# Run the "exit" command when receiving SIGNAL
trap "do_exit" SIGINT
trap "do_exit" SIGKILL
trap "do_exit" EXIT
trap "do_exit" SIGTERM
trap "do_exit" SIGHUP


echo $BUILDTIME_ANYCONNECT_PASSWORD | openconnect --authgroup $BUILDTIME_ANYCONNECT_GROUP $BUILDTIME_ANYCONNECT_SERVER --user=$BUILDTIME_ANYCONNECT_USER --timestamp --background
openconnectpid=$!

#
# During this sleep, the trap won't work as this is a blocking operation
#
sleep 10
echo "Preparing to mount CIFS share"
mount -t cifs //$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH /mnt/local_share  -o user=$BUILDTIME_ANYCONNECT_USER,password=$BUILDTIME_ANYCONNECT_PASSWORD
echo "Mounted CIFS share"

# wait forever
tail -f /dev/null & wait