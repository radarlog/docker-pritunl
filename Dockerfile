FROM golang:1.15-alpine3.12 as go-builder

ENV BUILD_DEPS git
ENV GOPATH /go

RUN set -ex \
    && cd ${GOPATH} \
    #
    # Install dependencies
    && apk --no-cache add --update $BUILD_DEPS \
    #
    # Build mkcert
    && go get -u -v github.com/pritunl/pritunl-dns \
    && go get -u -v github.com/pritunl/pritunl-web

FROM alpine:3.12

LABEL maintainer="Ilian Ranguelov <me@radarlog.net>"

ENV BUILD_DEPS curl \
    gcc \
    libffi-dev \
    libressl-dev \
    linux-headers \
    make \
    musl-dev \
    python2-dev
ENV RUNTIME_DEPS ca-certificates \
    ip6tables \
    iptables \
    libressl \
    net-tools \
    openvpn \
    procps \
    py2-setuptools \
    python2 \
    wireguard-tools
ENV PRITUNL_VERSION 1.29.2591.94
ENV PRITUNL_SHA1 53b6e6790f6493adc13fcd7af5baaa3df4118c14
ENV PRITUNL_URL https://github.com/pritunl/pritunl/archive/${PRITUNL_VERSION}.tar.gz
ENV PIP_URL https://bootstrap.pypa.io/get-pip.py

COPY --from=go-builder /go/bin/pritunl* /usr/bin/

RUN set -e \
    && cd /tmp \
    #
    # Install dependencies
    && apk --no-cache add --update ${RUNTIME_DEPS} ${BUILD_DEPS} \
    && curl -o get-pip.py -fSL ${PIP_URL} \
    && python2 get-pip.py --no-setuptools --no-wheel \
    #
    # Download and extract
    && curl -o pritunl.tar.gz -fSL ${PRITUNL_URL} \
    && echo "${PRITUNL_SHA1} *pritunl.tar.gz" | sha1sum -c - \
    && tar zxvf pritunl.tar.gz \
    && cd pritunl-${PRITUNL_VERSION} \
    #
    # Build
    && python2 setup.py build \
    && pip install -r requirements.txt \
    && python2 setup.py install \
    #
    # Clean up
    && apk del --purge $BUILD_DEPS \
    && rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /bin/entrypoint.sh

EXPOSE 9700 1194 1194/udp 51820/udp

ENTRYPOINT ["entrypoint.sh"]
CMD ["pritunl", "start"]
