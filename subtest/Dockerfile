FROM alpine:3.11.5
RUN apk upgrade --no-cache \
  && apk add --no-cache \
    # musl \
    build-base \
    python3 \
    python3-dev \
    bind-tools \
  && pip3 install --no-cache-dir --upgrade pip \
  && rm -rf /var/cache/* \
  && rm -rf /root/.cache/*

RUN cd /usr/bin \
  && ln -sf python3 python \
  && ln -sf pip3 pip

RUN pip3 install https://github.com/dlenski/vpn-slice/archive/master.zip

