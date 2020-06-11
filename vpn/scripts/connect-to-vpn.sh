#!/bin/sh

# 
# Set pidfile path
# 
OPENCONNECT_PROCESS_PIDFILE="/var/run/openconnect.pid"

function cleanup_on_exit() {
    echo "Cleanup vpn connection"
    if [ -f ${OPENCONNECT_PROCESS_PIDFILE} ] && ps -p $(< ${OPENCONNECT_PROCESS_PIDFILE}) &> /dev/null; then
        # Pid exists, kill process and remove pidfile
        [ ${UID} -ne 0 ] && echo "You must be root to run this script." && exit 1
        kill $(< ${OPENCONNECT_PROCESS_PIDFILE}) && rm -f ${OPENCONNECT_PROCESS_PIDFILE}
    fi
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

if [[ -z "${BUILDTIME_VPN_SERVER}" ]]; then
  echo 'Vpn server is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_VPN_USER}" ]]; then
  echo 'Vpn user is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_VPN_PASSWORD}" ]]; then
  echo 'Vpn user password is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_VPN_GROUP}" ]]; then
  echo 'Vpn user group is not defined. Process will exit'
  exit 1
fi

echo $BUILDTIME_VPN_PASSWORD | openconnect --servercert pin-sha256:${BUILDTIME_VPN_CERT_HASH} --no-dtls --authgroup $BUILDTIME_VPN_GROUP $BUILDTIME_VPN_SERVER --user=$BUILDTIME_VPN_USER --pid-file=${OPENCONNECT_PROCESS_PIDFILE} &
VPN_PROCESS=$!

[ $? -ne 0 ] && echo "Vpn failed to start!" && \
    rm -f ${OPENCONNECT_PROCESS_PIDFILE} && exit 1

#
# Wait non blocking.
#
# Unlike the sleep command, wait allows to react (trap) to signals
#
wait $VPN_PROCESS