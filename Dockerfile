### CONFIGURATION ###
#
# These values will be used by the Github Action to build images.
# Modify these in a PR, merge them, and push a tag with format 'v<YOUR_VERSION_HERE>' to auto-build a new image!
#
ARG ENVOY_IMAGE=envoyproxy/envoy:v1.23.1
ARG CONSUL_IMAGE=hashicorp/consul:1.13.1
#
### END CONFIGURATION ###

FROM ${ENVOY_IMAGE} as envoy-bin

FROM ${CONSUL_IMAGE} as consul-bin

FROM ubuntu 

ENV CONSUL_HTTP_ADDR=http://localhost:8500

RUN apt-get update && \
    apt-get install -y \
      bash \
      curl \
      jq && \
    rm -rf /var/lib/apt/lists/*

COPY --from=envoy-bin /usr/local/bin/envoy /bin/envoy
COPY --from=consul-bin /bin/consul /bin/consul

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]