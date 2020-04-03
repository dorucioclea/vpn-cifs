#
# Lockdown on alpine 3.11.5
#
ARG ALPINE_VERSION=3.11.5

FROM alpine:${ALPINE_VERSION}

#
# VERY IMPORTANT: In order for our entrypoint/command scripts to receive signal to stop, we need to specify that through STOPSIGNAL
#

STOPSIGNAL SIGINT

ARG NETWORK_SHARE_PASSWORD
ARG NETWORK_SHARE_USER
ARG NETWORK_SHARE_HOST
ARG NETWORK_SHARE_DIRECTORY

ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV BUILDTIME_NETWORK_SHARE_HOST=${NETWORK_SHARE_HOST}
ENV BUILDTIME_NETWORK_SHARE_DIRECTORY=${NETWORK_SHARE_DIRECTORY}
ENV BUILDTIME_NETWORK_SHARE_USER=${NETWORK_SHARE_USER}
ENV BUILDTIME_NETWORK_SHARE_PASSWORD=${NETWORK_SHARE_PASSWORD}

RUN apk add cifs-utils=6.9-r1 tini=0.18.0-r0 supervisor dos2unix wget --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/start-mount.sh /usr/bin/start-mount.sh

RUN mkdir -p /mnt/local_share

RUN dos2unix /usr/bin/start-mount.sh
RUN chmod +x /usr/bin/start-mount.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
