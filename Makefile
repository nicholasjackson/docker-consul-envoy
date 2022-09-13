.PHONY: build build_and_push

### CONFIGURATION ###
#
# Can be overridden by passing ENV variables to `make`
#
# Example : DOCKERHUB_REPO=ericreeves/consul-envoy CONSUL_REPO=hashicorp/consul-enterprise CONSUL_VERSION=1.13.1-ent make build_and_push
#

# Consul Base Repository and Image Tag
CONSUL_REPO    ?= hashicorp/consul
CONSUL_VERSION ?= 1.13.1

# Envoy Base Repository and Image Tag
ENVOY_REPO     ?= envoyproxy/envoy
ENVOY_VERSION  ?= 1.23.1

# Dockerhub Base Repository and Image Tag for our envoy-consul Image
DOCKERHUB_REPO ?= nicholasjackson/consul-envoy

### END CONFIGURATION ###

# Construct Full Image Names
CONSUL_IMAGE=${CONSUL_REPO}:${CONSUL_VERSION}
ENVOY_IMAGE=${ENVOY_REPO}:v${ENVOY_VERSION}
DOCKERHUB_IMAGE=${DOCKERHUB_REPO}:v${CONSUL_VERSION}-v${ENVOY_VERSION}

build:
	docker build --build-arg CONSUL_IMAGE=${CONSUL_IMAGE} --build-arg ENVOY_IMAGE=${ENVOY_IMAGE} -t "${DOCKERHUB_IMAGE}" .

build_and_push: build
	docker push "${DOCKERHUB_IMAGE}"
