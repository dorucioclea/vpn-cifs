#!/bin/sh
function stop() {
    echo "Cleanup mount process before exiting"
    # #
    # # Checks if we have a mount point on /mnt/local_share
    # #
    [[ "$(df -P /mnt/local_share | tail -1 | cut -d' ' -f 1)" == "//$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH" ]] && umount /mnt/local_share || echo "No mount point to clean up"

}

#
# Trap SIGTERM and SIGINT and execute 
#
# Run the "stop" command when receiving SIGNAL
trap "stop" SIGINT
trap "stop" SIGKILL
trap "stop" EXIT
trap "stop" SIGTERM
trap "stop" SIGHUP

# while [ 1 ]; do
#     wget -q --spider https://api.ipify.org
#     if [ $? -eq 0 ]; then
#         echo "VPN connectivity is up"
#         break
#     else
#         echo "Offline"
#     fi
#     sleep 1
# done

# sleep 20

echo "Mounting CIFS share"
mount -t cifs //$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH /mnt/local_share  -o user=$BUILDTIME_ANYCONNECT_USER,password=$BUILDTIME_ANYCONNECT_PASSWORD &
sleep 4
echo "CIFS share mounted"

# wait - non blocking
tail -f /dev/null & wait