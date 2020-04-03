#
# Lockdown on alpine 3.11.5
#
ARG ALPINE_VERSION=3.11.5

FROM alpine:${ALPINE_VERSION}

LABEL openconnect.documentation="https://www.infradead.org/openconnect/index.html"

#
# VERY IMPORTANT: In order for our entrypoint/command scripts to receive signal to stop, we need to specify that through STOPSIGNAL
#

STOPSIGNAL SIGINT

ARG VPN_SERVER
ARG VPN_GROUP
ARG VPN_PASSWORD
ARG VPN_USER

ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV BUILDTIME_VPN_SERVER=${VPN_SERVER}
ENV BUILDTIME_VPN_USER=${VPN_USER}
ENV BUILDTIME_VPN_PASSWORD=${VPN_PASSWORD}
ENV BUILDTIME_VPN_GROUP=${VPN_GROUP}

ENV OPENCONNECT_TIMESTAMP=true
ENV OPENCONNECT_VERBOSE=false
ENV OPENCONNECT_NON-INTER=true

RUN apk add \
    openconnect=8.05-r1 \
    tini=0.18.0-r0 \
    supervisor \
    dos2unix \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/connect-to-vpn.sh /usr/bin/connect-to-vpn.sh

RUN dos2unix /usr/bin/connect-to-vpn.sh
RUN chmod +x /usr/bin/connect-to-vpn.sh

#
# Define healthchecks for the image 
#

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
