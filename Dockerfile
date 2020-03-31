FROM alpine:3.11.5
RUN apk add openconnect --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

ADD entrypoint.sh /entrypoint.sh

#
# Elevate to root user to be able to run chmod
#

USER root
RUN chmod 755 /entrypoint.sh

HEALTHCHECK  --interval=10s --timeout=10s --start-period=10s \
CMD /sbin/ifconfig tun0
CMD ["/entrypoint.sh"]