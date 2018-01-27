FROM alpine:3.7

MAINTAINER Ilian Ranguelov <me@radarlog.net>

ENV BUILD_DEPS curl gcc git go musl-dev libffi-dev linux-headers openssl-dev py2-pip python-dev
ENV RUNTIME_DEPS openvpn openssl ca-certificates python py-setuptools

# Build dependencies
RUN apk --no-cache add --update ${RUNTIME_DEPS} ${BUILD_DEPS}

RUN pip install --upgrade pip

ENV PRITUNL_VERSION 1.28.1583.74
ENV PRITUNL_SHA1 6d21ec164381023bde3144b2fd0b6404e462382e
ENV PRITUNL_URL https://github.com/pritunl/pritunl/archive/${PRITUNL_VERSION}.tar.gz

# Pritunl Install
RUN export GOPATH=/go \
    && go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-monitor \
    && go get github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin/

RUN set -e \
    && cd /tmp \
    && curl -o pritunl.tar.gz -fSL ${PRITUNL_URL} \
    && echo "${PRITUNL_SHA1} *pritunl.tar.gz" | sha1sum -c - \
    && tar zxvf pritunl.tar.gz \
    && cd pritunl-${PRITUNL_VERSION} \
    && python setup.py build \
    && pip install -r requirements.txt \
    && python2 setup.py install

RUN set -e \
    && apk del --purge $BUILD_DEPS \
    && rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /bin/entrypoint.sh

EXPOSE 9700 1194 1194/udp

ENTRYPOINT ["entrypoint.sh"]
CMD ["pritunl", "start"]
