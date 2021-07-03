#!/bin/bash

function docker_tag_exists() {
  curl --silent -f -lSL https://hub.docker.com/v2/repositories/$1/tags/$2 > /dev/null 
}

consul_version=("1.10.0" "1.9.5" "1.9.3" "1.9.2" "1.8.3" "1.8.2" "1.8.1" "1.8.0" "1.7.4" "1.7.3" "1.7.2")
envoy_version=("1.18.3" "1.17.1" "1.16.2" "1.16.0" "1.15.3" "1.15.0" "1.14.4" "1.14.2" "1.13.4" "1.13.2" "1.13.1" "1.13.0" "1.12.6" "1.12.4" "1.12.3" "1.11.2" "1.10.0")

#consul_version=("1.10.0" "1.9.5" "1.9.3" "1.9.2")
#envoy_version=("1.18.3" "1.17.1" "1.16.2" "1.16.0")

# consul_version=("1.9.5")
# envoy_version=("1.16.2")

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multi || true
docker buildx use multi
docker buildx inspect --bootstrap

for c in ${consul_version[@]};do
	for e in ${envoy_version[@]};do
    # only build if the image does not exist in the repo
    if docker_tag_exists  nicholasjackson/consul-envoy v$c-v$e; then
      echo "Docker image nicholasjackson/consul-envoy v$c-v$e, already exists, skip build"
    else
      echo "Building Docker image nicholasjackson/consul-envoy v$c-v$e"
      echo ""

      docker buildx build --platform linux/arm64,linux/amd64 \
        --build-arg CONSUL_VERSION=$c \
        --build-arg ENVOY_VERSION=$e \
        -t nicholasjackson/consul-envoy:v$c-v$e \
         . \
      	--push
    fi
	done
done

docker buildx rm multi
