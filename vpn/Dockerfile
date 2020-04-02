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

ENV LANG=en_US.UTF-8
ENV TZ=UTC


ENV BUILDTIME_ANYCONNECT_SERVER=${ANYCONNECT_SERVER}
ENV BUILDTIME_ANYCONNECT_USER=${ANYCONNECT_USER}
ENV BUILDTIME_ANYCONNECT_PASSWORD=${ANYCONNECT_PASSWORD}
ENV BUILDTIME_ANYCONNECT_GROUP=${ANYCONNECT_GROUP}

RUN apk add openconnect=8.05-r1 tini=0.18.0-r0 supervisor dos2unix --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/start-vpn.sh /usr/bin/start-vpn.sh

RUN dos2unix /usr/bin/start-vpn.sh
RUN chmod +x /usr/bin/start-vpn.sh

#
# Define healthchecks for the image 
#

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
