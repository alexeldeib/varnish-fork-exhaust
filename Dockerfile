FROM docker.io/library/varnish:7.2.1

COPY default.vcl /etc/varnish/
COPY docker-varnish-entrypoint /usr/local/bin/docker-varnish-entrypoint
