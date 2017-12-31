FROM alpine:3.6

MAINTAINER Ilian Ranguelov <me@radarlog.net>

# Build dependencies
RUN apk --no-cache add --update go git curl openvpn openssl ca-certificates python \
    py2-pip py-setuptools gcc python-dev musl-dev linux-headers libffi-dev openssl-dev

RUN pip install --upgrade pip

ENV PRITUNL_VERSION 1.28.1548.86
ENV PRITUNL_SHA1 a7336d274bf68d0252dda5e85ad831ee9822579c

# Pritunl Install
RUN export GOPATH=/go \
    && go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-monitor \
    && go get github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin/

RUN set -e \
    && cd /tmp \
	&& curl -o pritunl.tar.gz -fSL "https://github.com/pritunl/pritunl/archive/${PRITUNL_VERSION}.tar.gz" \
	&& echo "${PRITUNL_SHA1} *pritunl.tar.gz" | sha1sum -c - \
	&& tar zxvf pritunl.tar.gz \
	&& cd pritunl-${PRITUNL_VERSION} \
	&& python setup.py build \
	&& pip install -r requirements.txt \
	&& python2 setup.py install \
	&& rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /bin/entrypoint.sh

EXPOSE 9700 1194 1194/udp

ENTRYPOINT ["entrypoint.sh"]
CMD ["pritunl", "start"]
