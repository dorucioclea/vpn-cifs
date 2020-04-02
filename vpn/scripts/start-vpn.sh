#!/bin/sh
echo 'Starting OPENCONNECT VPN client'

# Set pidfile
PIDFILE="/var/run/openconnect.pid"
PASSWORD_FILE="/vpndata/openconnect.pass"

function stop() {
    echo "Cleanup openconnect process before exiting"
    if [ -f ${PIDFILE} ] && ps -p $(< ${PIDFILE}) &> /dev/null; then
        # Pid exists, kill process and remove pidfile
        [ ${UID} -ne 0 ] && echo "You must be root to run this script." && exit 1
        kill $(< ${PIDFILE}) && rm -f ${PIDFILE}
    fi
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

if [[ -z "${BUILDTIME_ANYCONNECT_SERVER}" ]]; then
  echo 'ANYCONNECT_SERVER is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_ANYCONNECT_USER}" ]]; then
  echo 'ANYCONNECT_USER is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_ANYCONNECT_PASSWORD}" ]]; then
  echo 'ANYCONNECT_PASSWORD is not defined. Process will exit'
  exit 1
fi

if [[ -z "${BUILDTIME_ANYCONNECT_GROUP}" ]]; then
  echo 'ANYCONNECT_GROUP is not defined. Process will exit'
  exit 1
fi

echo $BUILDTIME_ANYCONNECT_PASSWORD | openconnect --authgroup $BUILDTIME_ANYCONNECT_GROUP $BUILDTIME_ANYCONNECT_SERVER --user=$BUILDTIME_ANYCONNECT_USER --pid-file=${PIDFILE} &

OPENVPN_SUBPROCESS=$!


[ $? -ne 0 ] && echo "OPENCONNECT VPN client failed to start!" && \
    rm -f ${PIDFILE} && exit 1

sleep 10
echo 'OPENCONNECT is up and running'
wait $OPENVPN_SUBPROCESS