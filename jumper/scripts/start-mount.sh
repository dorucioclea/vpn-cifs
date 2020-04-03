#!/bin/sh
function stop() {
    echo "Cleanup mount before exiting"
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


#
# Check we have all environment variables needed
#

if [[ -z "${BUILDTIME_ANYCONNECT_USER}" ]]; then
  echo 'USER is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_ANYCONNECT_PASSWORD}" ]]; then
  echo 'PASSWORD is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_CIFS_HOST}" ]]; then
  echo 'Cifs share host is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_CIFS_PATH}" ]]; then
  echo 'Cifs share path is not defined. Process will exit'
  exit 1
fi

sleep 10

mount -t cifs //$BUILDTIME_CIFS_HOST/$BUILDTIME_CIFS_PATH /mnt/local_share  -o user=$BUILDTIME_ANYCONNECT_USER,password=$BUILDTIME_ANYCONNECT_PASSWORD &
echo "CIFS share mounted"

# wait - non blocking
tail -f /dev/null & wait