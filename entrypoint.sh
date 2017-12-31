#!/bin/sh

pritunl set-mongodb mongodb://${MONGODB_SERVER}/pritunl
pritunl set app.reverse_proxy true
pritunl set app.server_ssl false
pritunl set app.server_port 9700

exec $@
