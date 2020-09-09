#!/bin/bash

echo "Testing Consul Envoy Compatibility"
echo ""

echo "Consul Version | Envoy Version | Result"
echo "-------------- | ------------- | ------"

consul_version=("1.8.3" "1.8.2" "1.8.0" "1.7.2")
envoy_version=("1.15.0" "1.14.4" "1.14.2" "1.13.2" "1.13.1" "1.12.4" "1.12.3" "1.11.2" "1.10.0")

#consul_version=("1.8.0")
#envoy_version=("1.11.2")

for c in ${consul_version[@]};do
  for e in ${envoy_version[@]};do
    ENVOY_VERSION=$e CONSUL_VERSION=$c shipyard run ./consul-docker > /dev/null 2>&1

    broken=1

    for i in {1..30}; do
      $(curl -s localhost:9090 -H "x-version:2" | grep -q "Backend_Service 2")
      if [ $? == 0 ]; then
        broken=0
        break
      fi

      sleep 1
    done

    if [ $broken == 1 ]; then
      printf "%14s | %13s | FAIL\n" $c $e
    else 
      printf "%14s | %13s | PASS\n" $c $e
    fi

    shipyard destroy > /dev/null 2>&1
  done
done;