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
    gcc musl-dev \
    dos2unix \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

COPY /deps/vpn-slice-master.zip /usr/bin/deps/vpn-slice.zip

RUN apk add --no-cache bind-tools
RUN pip3 install --user --verbose /usr/bin/deps/vpn-slice.zip

# always add the docker DNS server

RUN grep -qxF 'nameserver 127.0.0.11' /etc/resolv.conf || echo 'nameserver 127.0.0.11' >> /etc/resolv.conf

COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/connect-to-vpn.sh /usr/bin/connect-to-vpn.sh

# Use an up-to-date version of vpnc-script
# https://www.infradead.org/openconnect/vpnc-script.html
COPY scripts/vpnc-script /etc/vpnc/vpnc-script

RUN dos2unix /usr/bin/connect-to-vpn.sh
RUN chmod +x /usr/bin/connect-to-vpn.sh
RUN chmod 755 /etc/vpnc/vpnc-script

#
# Define healthchecks for the image 
#

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
