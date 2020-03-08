FROM alpine:3.11

MAINTAINER Ilian Ranguelov <me@radarlog.net>

ENV BUILD_DEPS curl gcc git go make musl-dev libffi-dev linux-headers libressl-dev py2-pip python-dev
ENV RUNTIME_DEPS openvpn libressl ca-certificates python py-setuptools

ENV PRITUNL_VERSION 1.29.2276.91
ENV PRITUNL_SHA1 4f4d69e2ef53e65823e30ae6568b1fe232600117
ENV PRITUNL_URL https://github.com/pritunl/pritunl/archive/${PRITUNL_VERSION}.tar.gz

RUN set -e \
    && cd /tmp \
    #
    # Install dependencies
    && apk --no-cache add --update ${RUNTIME_DEPS} ${BUILD_DEPS} \
    && pip install --upgrade pip \
    #
    # Install additional components
    && export GOPATH=/go \
    && go get -u github.com/pritunl/pritunl-dns \
    && go get -u github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin/ \
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
    && rm -rf /tmp/* /var/cache/apk/* /go/*

COPY entrypoint.sh /bin/entrypoint.sh

EXPOSE 9700 1194 1194/udp

ENTRYPOINT ["entrypoint.sh"]
CMD ["pritunl", "start"]
