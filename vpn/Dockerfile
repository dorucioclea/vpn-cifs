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
ARG VPN_CERT_HASH

ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV BUILDTIME_VPN_SERVER=${VPN_SERVER}
ENV BUILDTIME_VPN_USER=${VPN_USER}
ENV BUILDTIME_VPN_PASSWORD=${VPN_PASSWORD}
ENV BUILDTIME_VPN_GROUP=${VPN_GROUP}
ENV BUILDTIME_VPN_CERT_HASH=${VPN_CERT_HASH}

ENV OPENCONNECT_TIMESTAMP=true
ENV OPENCONNECT_VERBOSE=false
ENV OPENCONNECT_NON-INTER=true

# Refresh apk index
RUN apk --update --no-progress  --no-cache upgrade
RUN apk add \
    dos2unix \
    supervisor \
    tini=0.18.0-r0 \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/


# always add the docker DNS server
RUN grep -qxF 'nameserver 127.0.0.11' /etc/resolv.conf || echo 'nameserver 127.0.0.11' >> /etc/resolv.conf
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY scripts/connect-to-vpn.sh /usr/bin/connect-to-vpn.sh

# Use an up-to-date version of vpnc-script
# https://www.infradead.org/openconnect/vpnc-script.html

COPY scripts/vpnc-script /etc/vpnc/vpnc-script
RUN dos2unix /usr/bin/connect-to-vpn.sh
RUN dos2unix /etc/vpnc/vpnc-script
RUN chmod +x /usr/bin/connect-to-vpn.sh
RUN chmod 755 /etc/vpnc/vpnc-script

RUN mkdir -p /tmp/build/openconnect
COPY deps/libs/openconnect-8.10.tar.gz /tmp/openconnect.tar.gz
RUN tar -xf /tmp/openconnect.tar.gz -C /tmp/build/openconnect --strip-components=1

RUN set -ex \

            ## Install runtime dependencies

            && apk add --no-progress --virtual .openconnect-run-deps \
                    gnutls gnutls-utils iptables libev libintl \
                    libnl3 libseccomp linux-pam openssl \
                    libxml2 nmap-ncat socat openssh-client \
                    p11-kit libproxy \

            ## Install build dependencies - these are deleted after the build

            && apk add --no-progress --virtual .openconnect-build-deps \
                    curl file g++ gnutls-dev gpgme gzip libev-dev \
                    libnl3-dev libseccomp-dev libxml2-dev  linux-headers \
                    linux-pam-dev make readline-dev tar \
                    sed readline procps \

            ## Build and install

            && cd /tmp/build/openconnect \
            && ./configure \
            && make \
            && make install \
            && cd / \

            # Cleanup

            && apk del .openconnect-build-deps

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
