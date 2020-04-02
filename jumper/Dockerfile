#
# Lockdown on alpine 3.11.5
#
ARG ALPINE_VERSION=3.11.5

FROM alpine:${ALPINE_VERSION}

#
# VERY IMPORTANT: In order for our entrypoint/command scripts to receive signal to stop, we need to specify that through STOPSIGNAL
#

STOPSIGNAL SIGINT

ARG ANYCONNECT_PASSWORD
ARG ANYCONNECT_USER
ARG ANYCONNECT_CIFS_HOST
ARG ANYCONNECT_CIFS_PATH

ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV BUILDTIME_CIFS_HOST=${ANYCONNECT_CIFS_HOST}
ENV BUILDTIME_CIFS_PATH=${ANYCONNECT_CIFS_PATH}
ENV BUILDTIME_ANYCONNECT_USER=${ANYCONNECT_USER}
ENV BUILDTIME_ANYCONNECT_PASSWORD=${ANYCONNECT_PASSWORD}

RUN apk add cifs-utils=6.9-r1 tini=0.18.0-r0 supervisor dos2unix wget --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/start-mount.sh /usr/bin/start-mount.sh

RUN mkdir -p /mnt/local_share

RUN dos2unix /usr/bin/start-mount.sh
RUN chmod +x /usr/bin/start-mount.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
