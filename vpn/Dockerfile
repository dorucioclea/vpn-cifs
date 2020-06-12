#
# Lockdown on alpine 3.11.5
#
ARG ALPINE_VERSION=3.11.5

FROM alpine:${ALPINE_VERSION}

LABEL openconnect.documentation="https://www.infradead.org/openconnect/index.html"

#
# In order for our entrypoint/command scripts to receive signal to stop
#
#  we need to specify that through STOPSIGNAL
#

STOPSIGNAL SIGINT

#
# Define list of arguments
#
ARG VPN_SERVER
ARG VPN_GROUP
ARG VPN_PASSWORD
ARG VPN_USER
ARG VPN_CERT_HASH

#
# Assign environment variables for the VPN script
#
# from the arguments received above
#
ENV BUILDTIME_VPN_SERVER=${VPN_SERVER}
ENV BUILDTIME_VPN_USER=${VPN_USER}
ENV BUILDTIME_VPN_PASSWORD=${VPN_PASSWORD}
ENV BUILDTIME_VPN_GROUP=${VPN_GROUP}
ENV BUILDTIME_VPN_CERT_HASH=${VPN_CERT_HASH}

ENV OPENCONNECT_TIMESTAMP=true
ENV OPENCONNECT_VERBOSE=false
ENV OPENCONNECT_NON-INTER=true

ENV LANG=en_US.UTF-8
ENV TZ=UTC

# 
# Refresh apk index and upgrade
#
RUN apk --update --no-progress  --no-cache upgrade

#
# Add run utils
#
RUN apk add \
    dos2unix \
    supervisor \
    tini=0.18.0-r0 \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

#
# Always add the docker DNS server
#
# This IP address represents Docker's embedded DNS server and will be used for any container which 
# is connected to a user-defined network. 
#
# It is a requirement that any container connected to a user-defined use the embedded DNS server.
#
# Below we check if it's already in /etc/resolv.conf and if it's not, we add it
#
RUN grep -qxF 'nameserver 127.0.0.11' /etc/resolv.conf || echo 'nameserver 127.0.0.11' >> /etc/resolv.conf

#
# Use an up-to-date version of vpnc-script
# https://www.infradead.org/openconnect/vpnc-script.html
#
# Convert it to unix line endings
# Make it an executable
#
# We also patch the Docker nameserver in - these are changes 
# over the original file that can be found at the above url
#

COPY scripts/vpnc-script /etc/vpnc/vpnc-script
RUN dos2unix /etc/vpnc/vpnc-script
RUN chmod 755 /etc/vpnc/vpnc-script

#
# Copy connect to vpn script
# Convert it to unix line endings
# Make it an executable
#
COPY scripts/connect-to-vpn.sh /usr/bin/connect-to-vpn.sh
RUN dos2unix /usr/bin/connect-to-vpn.sh
RUN chmod +x /usr/bin/connect-to-vpn.sh

#
# Copy the supervisord script
#
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf

#
# Copy the openconnect library dependency
#
RUN mkdir -p /tmp/build/openconnect
COPY deps/libs/openconnect-8.10.tar.gz /tmp/openconnect.tar.gz
RUN tar -xf /tmp/openconnect.tar.gz -C /tmp/build/openconnect --strip-components=1

#
# Install the build dependencies - these will be uninstalled at the end
#
RUN apk add --no-progress --virtual .build-deps \
        bash \
        autoconf \
        automake \
        libtool \
        libxml2-dev \
        curl \
        file \
        g++ \
        gnutls-dev \
        gpgme \
        gzip \
        libev-dev \
        libnl3-dev \
        libseccomp-dev \
        libxml2-dev  \
        linux-headers \
        linux-pam-dev \
        make \
        readline-dev \
        tar \
        sed \
        readline \
        procps

#
# Install runtime dependencies
#
RUN apk add --no-progress --virtual .openconnect-run-deps \
        gnutls \
        gnutls-utils \
        iptables \
        libev \
        libintl \
        libnl3 \
        libseccomp \
        linux-pam \
        openssl \
        libxml2 \
        nmap-ncat \
        socat \
        openssh-client \
        p11-kit \
        libproxy

#
# Copy the stoken library dependency
#
RUN mkdir -p /tmp/build/stoken
COPY deps/libs/stoken-0.92.tar.gz /tmp/stoken.tar.gz
RUN tar -xf /tmp/stoken.tar.gz -C /tmp/build/stoken --strip-components=1

#
# Build and install stoken
#
RUN cd /tmp/build/stoken \
        && bash autogen.sh \
        && ./configure \
        && make install \
        && make \
        && cd /

#
# Build and install openconnect
#
RUN set -ex \
        && cd /tmp/build/openconnect \
        && ./configure --with-vpnc-script=/etc/vpnc/vpnc-script \
        && make \
        && make install \
        && cd /

#
# Remove build dependencies for openconnect and stoken
#
RUN apk del .build-deps

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
