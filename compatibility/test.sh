#!/bin/bash

echo "Testing Consul Envoy Compatibility"
echo ""

echo "Consul Version | Envoy Version | Routing | Traffic Split"
echo "-------------- | ------------- | ------- | -------------"

#consul_version=("1.8.3" "1.8.2" "1.8.0" "1.7.2")
#envoy_version=("1.15.0" "1.14.4" "1.14.2" "1.13.2" "1.13.1" "1.13.0" "1.12.4" "1.12.3" "1.11.2" "1.10.0")

consul_version=("1.12.2" "1.12.0" "1.11.2" "1.10.7" "1.10.0" "1.9.5" "1.9.3" "1.9.2" "1.8.3" "1.8.2" "1.8.1" "1.8.0" "1.7.4" "1.7.3" "1.7.2")
envoy_version=("1.22.2" "1.22.1" "1.22.0" "1.21.2" "1.20.1" "1.18.1" "1.18.4" "1.18.3" "1.17.1" "1.16.2" "1.16.0" "1.15.3" "1.15.0" "1.14.4" "1.14.2" "1.13.4" "1.13.2" "1.13.1" "1.13.0" "1.12.6" "1.12.4" "1.12.3" "1.11.2" "1.10.0")

#consul_version=("1.8.2")
#envoy_version=("1.13.0")

for c in ${consul_version[@]};do
  for e in ${envoy_version[@]};do
    ENVOY_VERSION=$e CONSUL_VERSION=$c shipyard run ./consul-docker > /dev/null 2>&1

    routing=FAIL
    splitting=FAIL

    for i in {1..30}; do
      $(curl -s localhost:9090 -H "x-version:2" | grep -q "Backend_Service 2")
      if [ $? == 0 ]; then
        routing=PASS
      fi

      $(curl -s localhost:9090 | grep -q "Backend_Service 1")
      if [ $? == 0 ]; then
        splitting=PASS
      fi

      if [[ "${routing}" == "PASS" && "$splitting" == "PASS" ]]; then
        break
      fi

      sleep 1
    done

    printf "%14s | %13s | %7s | %13s\n" $c $e $routing $splitting

    shipyard destroy > /dev/null 2>&1
  done
done;
