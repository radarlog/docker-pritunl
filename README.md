# Pritunl
[Pritunl](https://github.com/pritunl/pritunl) is a distributed enterprise
vpn server built using the OpenVPN protocol. Documentation and more
information can be found at the home page [pritunl.com](https://pritunl.com)

## FEATURES
Current docker image is built from [alpine](https://hub.docker.com/_/alpine/) for using behind a reverse proxy. In order to simplify a network communication between services SSL-protocol is turned off as well as activated an appropriate working mode.

## USAGE
Pritunl requires a MongoDB database as a backend storage. You must set your own one by `MONGODB_URI` environment variable:

```shell
docker run -d --privileged \
	-e MONGODB_URI=mongodb://mongodb-host:27017/pritunl \
	-p 9700:9700 \
	-p 1194:1194/udp \
	-p 1194:1194/tcp \
	radarlog/pritunl
```
Pritunl web console is accessible at `http://pritunl-host:9700` with default username `pritunl` and password `pritunl`.
