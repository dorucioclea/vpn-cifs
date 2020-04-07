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
ARG VPN_PROTECTED_ROUTES

ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV BUILDTIME_VPN_SERVER=${VPN_SERVER}
ENV BUILDTIME_VPN_USER=${VPN_USER}
ENV BUILDTIME_VPN_PASSWORD=${VPN_PASSWORD}
ENV BUILDTIME_VPN_GROUP=${VPN_GROUP}
ENV BUILDTIME_VPN_PROTECTED_ROUTES=${VPN_PROTECTED_ROUTES}

ENV OPENCONNECT_TIMESTAMP=true
ENV OPENCONNECT_VERBOSE=false
ENV OPENCONNECT_NON-INTER=true

RUN apk upgrade --no-cache

RUN apk add \
    openconnect=8.05-r1 \
    dos2unix \
    supervisor \
    tini=0.18.0-r0 \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

#
# For a more advanced control over routing, uncomment this and also use the vpn-slice commented line in the connect-to-vpn.sh script
#
#  RUN apk add --no-cache \
#     build-base \
#     python3 \
#     python3-dev \
#     bind-tools \
#   && pip3 install --no-cache-dir --upgrade pip \
#   && rm -rf /var/cache/* \
#   && rm -rf /root/.cache/*

# RUN cd /usr/bin \
#   && ln -sf python3 python \
#   && ln -sf pip3 pip

# RUN mkdir -p /deps
# COPY /deps/vpn-slice-master.zip /deps/vpn-slice.zip
# RUN pip3 install /deps/vpn-slice.zip

# always add the docker DNS server

RUN grep -qxF 'nameserver 127.0.0.11' /etc/resolv.conf || echo 'nameserver 127.0.0.11' >> /etc/resolv.conf
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/connect-to-vpn.sh /usr/bin/connect-to-vpn.sh

# Use an up-to-date version of vpnc-script
# https://www.infradead.org/openconnect/vpnc-script.html

COPY scripts/vpnc-script /etc/vpnc/vpnc-script

RUN dos2unix /usr/bin/connect-to-vpn.sh
# RUN dos2unix /etc/vpnc/vpnc-script
RUN chmod +x /usr/bin/connect-to-vpn.sh
RUN chmod 755 /etc/vpnc/vpnc-script

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
