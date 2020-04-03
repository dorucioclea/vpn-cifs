#!/bin/sh
function cleanup_on_exit() {
    echo "Cleanup network share before exiting"
    # Checks if we have a mount point on /mnt/local_share
    [[ "$(df -P /mnt/local_share | tail -1 | cut -d' ' -f 1)" == "//$BUILDTIME_NETWORK_SHARE_HOST/$BUILDTIME_NETWORK_SHARE_DIRECTORY" ]] \
        && umount /mnt/local_share \
        || echo "No network share originating in //$BUILDTIME_NETWORK_SHARE_HOST/$BUILDTIME_NETWORK_SHARE_DIRECTORY found"
}

#
# Trap SIGTERM and SIGINT and execute 
#
# Run the "stop" command when receiving SIGNAL
trap "cleanup_on_exit" SIGINT
trap "cleanup_on_exit" SIGKILL
trap "cleanup_on_exit" EXIT
trap "cleanup_on_exit" SIGTERM
trap "cleanup_on_exit" SIGHUP


#
# Check we have all environment variables needed
#

if [[ -z "${BUILDTIME_NETWORK_SHARE_USER}" ]]; then
  echo 'Network share user is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_NETWORK_SHARE_PASSWORD}" ]]; then
  echo 'Network share password is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_NETWORK_SHARE_HOST}" ]]; then
  echo 'Network share share host is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_NETWORK_SHARE_DIRECTORY}" ]]; then
  echo 'Network share path is not defined. Process will exit'
  exit 1
fi

sleep 10

mount -t cifs //$BUILDTIME_NETWORK_SHARE_HOST/$BUILDTIME_NETWORK_SHARE_DIRECTORY /mnt/local_share  -o user=$BUILDTIME_NETWORK_SHARE_USER,password=$BUILDTIME_NETWORK_SHARE_PASSWORD &

[ $? -ne 0 ] && echo "Could not mount network share" || echo "Network share mounted"

#
# Wait non blocking.
#
# Unlike the sleep command, wait allows to react (trap) to signals
#
tail -f /dev/null & wait