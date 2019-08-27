FROM envoyproxy/envoy-alpine:v1.10.0

RUN apk add -u bash curl
RUN wget https://releases.hashicorp.com/consul/1.6.0/consul_1.6.0_linux_amd64.zip -O /tmp/consul.zip
RUN unzip /tmp/consul.zip -d /tmp
RUN mv /tmp/consul /usr/local/bin/consul

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
