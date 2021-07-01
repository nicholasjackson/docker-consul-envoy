ARG ENVOY_VERSION
ARG CONSUL_VERSION

FROM consul:${CONSUL_VERSION} as consul-bin

FROM envoyproxy/envoy-alpine:v${ENVOY_VERSION}

ENV CONSUL_HTTP_ADDR=http://localhost:8500

RUN apk add -u bash curl jq
COPY --from=consul-bin /bin/consul /bin/consul

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]