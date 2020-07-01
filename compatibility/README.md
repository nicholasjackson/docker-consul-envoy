# Consul Envoy Compatibility

This folder runs compatibility tests with a simple L7 config against different combos of Consul and Envoy

## Requirements

* [Shipyard](https://shipyard.run/docs/install)
* Docker

## Running tests

To run the tests use the `test.sh` script inside this folder. The script will create a single node Consul
cluster with a 2 teir app and execute a simple test for L7 routing.

Every Consul / Envoy combination is run against a fresh cluster and application, each iteration takes approximately 30s to run.

```
➜ ./test.sh 
Testing Consul Envoy Compatibility

Consul Version | Envoy Version | Result
-------------- | ------------- | ------
         1.8.0 |        1.14.2 | FAIL
         1.8.0 |        1.13.2 | FAIL
         1.8.0 |        1.13.1 | FAIL
         1.8.0 |        1.12.4 | PASS
         1.8.0 |        1.12.3 | PASS
         1.8.0 |        1.11.2 | PASS
         1.8.0 |        1.10.0 | FAIL
         1.7.2 |        1.14.2 | FAIL
         1.7.2 |        1.13.2 | FAIL
         1.7.2 |        1.13.1 | FAIL
         1.7.2 |        1.12.4 | PASS
         1.7.2 |        1.12.3 | PASS
         1.7.2 |        1.11.2 | PASS
         1.7.2 |        1.10.0 | FAIL
```

To add more Consul / Envoy versions to the test matrix you can edit the following variables in the `test.sh` script.

```
consul_version=("1.8.0" "1.7.2")
envoy_version=("1.14.2" "1.13.2" "1.13.1" "1.12.4" "1.12.3" "1.11.2" "1.10.0")
```