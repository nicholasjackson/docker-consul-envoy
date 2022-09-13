#!/bin/bash

function docker_tag_exists() {
  curl --silent -f -lSL https://hub.docker.com/v2/repositories/$1/tags/$2 > /dev/null
}

# This can be overriden by passing an environment variable
: ${DOCKERHUB_USERNAME:="nicholasjackson"}

CONSUL_REPO="hashicorp/consul"
CONSUL_VERSION=("1.12.2" "1.12.0" "1.11.2" "1.10.7" "1.10.0" "1.9.5" "1.9.3" "1.9.2" "1.8.3" "1.8.2" "1.8.1" "1.8.0" "1.7.4" "1.7.3" "1.7.2")

ENVOY_REPO="envoyproxy/envoy"
ENVOY_VERSION=("1.22.2" "1.22.1" "1.22.0" "1.21.2" "1.20.1" "1.18.1" "1.18.4" "1.18.3" "1.17.1" "1.16.2" "1.16.0" "1.15.3" "1.15.0" "1.14.4" "1.14.2" "1.13.4" "1.13.2" "1.13.1" "1.13.0" "1.12.6" "1.12.4" "1.12.3" "1.11.2" "1.10.0")

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multi || true
docker buildx use multi
docker buildx inspect --bootstrap

for c in ${CONSUL_VERSION[@]};do
	for e in ${ENVOY_VERSION[@]};do
    # only build if the image does not exist in the repo
    if docker_tag_exists  ${DOCKERHUB_USERNAME}/consul-envoy v$c-v$e; then
      echo "Docker image ${DOCKERHUB_USERNAME}/consul-envoy v$c-v$e, already exists, skip build"
    else
      echo "Building Docker image ${DOCKERHUB_USERNAME}/consul-envoy v$c-v$e"
      echo ""

      docker buildx build --platform linux/arm64,linux/amd64 \
        --build-arg CONSUL_IMAGE=${CONSUL_REPO}:$c \
        --build-arg ENVOY_IMAGE=${ENVOY_REPO}:v$e \
        -t ${DOCKERHUB_USERNAME}/consul-envoy:v$c-v$e \
         . \
      	--push
    fi
	done
done

docker buildx rm multi
