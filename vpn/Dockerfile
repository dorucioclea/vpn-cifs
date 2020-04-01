#
# Lockdown on alpine 3.11.5
#
ARG ALPINE_VERSION=3.11.5

FROM alpine:${ALPINE_VERSION}

ARG ANYCONNECT_SERVER
ARG ANYCONNECT_GROUP
ARG ANYCONNECT_PASSWORD
ARG ANYCONNECT_USER
ARG CIFS_HOST
ARG CIFS_PATH

ENV BUILDTIME_ANYCONNECT_SERVER=${ANYCONNECT_SERVER}
ENV BUILDTIME_ANYCONNECT_USER=${ANYCONNECT_USER}
ENV BUILDTIME_ANYCONNECT_PASSWORD=${ANYCONNECT_PASSWORD}
ENV BUILDTIME_ANYCONNECT_GROUP=${ANYCONNECT_GROUP}
ENV BUILDTIME_CIFS_HOST=${CIFS_HOST}
ENV BUILDTIME_CIFS_PATH=${CIFS_PATH}

RUN apk add openconnect cifs-utils --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

ADD entrypoint.sh /entrypoint.sh
RUN mkdir -p /mnt/local_share

#
# Elevate to root user to be able to run chmod
#

USER root
RUN chmod 755 /entrypoint.sh

HEALTHCHECK  --interval=10s --timeout=10s --start-period=10s \
CMD /sbin/ifconfig tun0
CMD ["/entrypoint.sh"]