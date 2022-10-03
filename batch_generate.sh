#!/bin/bash

DOCKERHUB_REPO="nicholasjackson/consul-envoy"

CONSUL_REPO="hashicorp/consul"
CONSUL_ENTERPRISE_REPO="hashicorp/consul-enterprise"
ENVOY_REPO="envoyproxy/envoy"

CONSUL_VERSION=$(curl https://registry.hub.docker.com/v2/repositories/library/consul/tags  | jq -r '.results[]["name"]' | sort -V -r)
CONSUL_ENTERPRISE_VERSION=$(curl https://registry.hub.docker.com/v2/repositories/hashicorp/consul-enterprise/tags  | jq -r '.results[]["name"]' | sort -V -r)
ENVOY_VERSION=$(curl https://registry.hub.docker.com/v2/repositories/envoyproxy/envoy/tags  | jq -r '.results[]["name"]' | sort -V -r)

function docker_tag_exists() {
  curl --silent -f -lSL https://hub.docker.com/v2/repositories/$1/tags/$2 > /dev/null
}

function build_containers() {
  echo "Consul Repo: $1"
  echo "Docker Repo: $DOCKERHUB_REPO"
  echo ""
  echo "Running for Consul versions:"
  echo "$2"
  echo " "
  echo "and Envoy versions:"
  echo "$3"
  
  # Build OSS
  for c in $2;do
    if [ "$c" != "latest" ]; then
  	  for e in $3;do
        # only build if the image does not exist in the repo
        if docker_tag_exists  $DOCKERHUB_REPO $c-$e; then
          echo "Docker image $DOCKERHUB_REPO $c-$e, already exists, skip build"
        else
          echo "Building Docker image $DOCKERHUB_REPO $c-$e"
          echo ""
  
          docker buildx build --platform linux/arm64,linux/amd64 \
            --build-arg CONSUL_IMAGE=$1:$c \
            --build-arg ENVOY_IMAGE=$ENVOY_REPO:$e \
            -t $DOCKERHUB_REPO:$c-$e \
             . \
          	--push

          echo "Signing with CoSign, verification of this image should use the following public key"
          cosign public-key
          echo ""
          cosign sign $DOCKERHUB_REPO:$c-$e
        fi
  	  done
    fi
  done
}

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multi || true
docker buildx use multi
docker buildx inspect --bootstrap

# Build OSS
echo "Building OSS"
build_containers "${CONSUL_REPO}" "${CONSUL_VERSION[@]}" "${ENVOY_VERSION[@]}"

# Build Enterprise
echo "Building Enterprise"
build_containers "${CONSUL_ENTERPRISE_REPO}" "${CONSUL_ENTERPRISE_VERSION[@]}" "${ENVOY_VERSION[@]}"

docker buildx rm multi
