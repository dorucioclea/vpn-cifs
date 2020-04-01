#
# Lockdown on alpine 3.11.5
#
ARG ALPINE_VERSION=3.11.5

FROM alpine:${ALPINE_VERSION}

#
# VERY IMPORTANT: In order for our entrypoint/command scripts to receive signal to stop, we need to specify that through STOPSIGNAL
#

STOPSIGNAL SIGINT

ARG ANYCONNECT_SERVER
ARG ANYCONNECT_GROUP
ARG ANYCONNECT_PASSWORD
ARG ANYCONNECT_USER
ARG ANYCONNECT_CIFS_HOST
ARG ANYCONNECT_CIFS_PATH

ENV LANG=en_US.UTF-8
ENV TZ=UTC


ENV BUILDTIME_ANYCONNECT_SERVER=${ANYCONNECT_SERVER}
ENV BUILDTIME_ANYCONNECT_USER=${ANYCONNECT_USER}
ENV BUILDTIME_ANYCONNECT_PASSWORD=${ANYCONNECT_PASSWORD}
ENV BUILDTIME_ANYCONNECT_GROUP=${ANYCONNECT_GROUP}
ENV BUILDTIME_CIFS_HOST=${ANYCONNECT_CIFS_HOST}
ENV BUILDTIME_CIFS_PATH=${ANYCONNECT_CIFS_PATH}

RUN apk add openconnect=8.05-r1 cifs-utils=6.9-r1 tini=0.18.0-r0 --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

ADD entrypoint.sh /entrypoint.sh
RUN mkdir -p /mnt/local_share
#
# Elevate to root user to be able to run chmod
#

USER root

#
# Make the entrypoint script executable
#

RUN chmod 755 /entrypoint.sh

#
# Define healthchecks for the image 
#
HEALTHCHECK  --interval=10s --timeout=10s --start-period=10s \
CMD /sbin/ifconfig tun0

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
