FROM envoyproxy/envoy-alpine:v1.12.2

RUN apk add -u bash curl &&\
    wget https://releases.hashicorp.com/consul/1.7.0/consul_1.7.0_linux_amd64.zip -O /tmp/consul.zip &&\
    unzip /tmp/consul.zip -d /tmp &&\
    mv /tmp/consul /usr/local/bin/consul

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
