container "api" {
  image {
    name = "nicholasjackson/fake-service:v0.13.2"
  }

  network { 
    name = "network.onprem"
    ip_address = "10.5.0.200"
  }

  env {
    key = "LISTEN_ADDR"
    value = "0.0.0.0:9090"
  }

  env {
    key = "NAME"
    value = "API"
  }
  
  env {
    key = "MESSAGE"
    value = "Hello from API_1"
  }
  
  env {
    key = "UPSTREAM_URIS"
    value = "http://localhost:9091"
  }

  port {
    local  = "9090"
    remote = "9090"
    host   = "9090"
  }
}

sidecar "api_envoy" {
  target = "container.api"
  
  image {
    name = "nicholasjackson/consul-envoy:v${env("CONSUL_VERSION")}-v${env("ENVOY_VERSION")}"
  }

  command = ["consul", "connect", "envoy","-sidecar-for", "api-1"]
  
  env {
    key = "SERVICE_ID"
    value = "api-1"
  }
  
  env {
    key = "SERVICE_CONFIG"
    value = "/files/api_1.hcl"
  }
  
  env {
    key = "CONSUL_HTTP_ADDR"
    value = "consul-1.container.shipyard.run:8500"
  }
  
  env {
    key = "CONSUL_GRPC_ADDR"
    value = "consul-1.container.shipyard.run:8502"
  }
  
  volume {
    source      = "./files"
    destination = "/files"
  }
  
  
}

container "backend_1" {
  image {
    name = "nicholasjackson/fake-service:v0.13.2"
  }

  network { 
    name = "network.onprem"
    ip_address = "10.5.0.201"
  }

  env {
    key = "LISTEN_ADDR"
    value = "127.0.0.1:9090"
  }

  env {
    key = "NAME"
    value = "Backend_Service 1"
  }
  
  env {
    key = "MESSAGE"
    value = "Hello from Backend_Service 1"
  }
}

sidecar "backend_1_envoy" {
  target = "container.backend_1"
  
  image {
    name = "nicholasjackson/consul-envoy:v${env("CONSUL_VERSION")}-v${env("ENVOY_VERSION")}"
  }
  
  command = ["consul", "connect", "envoy","-sidecar-for", "backend-1"]
  
  env {
    key = "SERVICE_ID"
    value = "backend-1"
  }
  
  env {
    key = "SERVICE_CONFIG"
    value = "/files/backend_1.hcl"
  }
  
  env {
    key = "CENTRAL_CONFIG"
    value = "/files/proxy_defaults.hcl;/files/resolver.hcl;/files/router.hcl"
  }
  
  env {
    key = "CONSUL_HTTP_ADDR"
    value = "consul-1.container.shipyard.run:8500"
  }
  
  env {
    key = "CONSUL_GRPC_ADDR"
    value = "consul-1.container.shipyard.run:8502"
  }
  
  volume {
    source      = "./files"
    destination = "/files"
  }
}

container "backend_2" {
  image {
    name = "nicholasjackson/fake-service:v0.13.2"
  }

  volume {
    source      = "./files/backend_2.hcl"
    destination = "/config/backend_2.hcl"
  }

  network { 
    name = "network.onprem"
    ip_address = "10.5.0.202"
  }
  
  env {
    key = "CONSUL_SERVER"
    value = "consul-1.container.shipyard.run"
  }
  
  env {
    key = "SERVICE_ID"
    value = "backend-2"
  }
  
  env {
    key = "LISTEN_ADDR"
    value = "127.0.0.1:9090"
  }

  env {
    key = "NAME"
    value = "Backend_Service 2"
  }
  
  env {
    key = "MESSAGE"
    value = "Hello from Backend Service"
  }
}

sidecar "backend_2_envoy" {
  target = "container.backend_2"
  
  image {
    name = "nicholasjackson/consul-envoy:v${env("CONSUL_VERSION")}-v${env("ENVOY_VERSION")}"
  }
  
  command = ["consul", "connect", "envoy","-sidecar-for", "backend-2"]
  
  env {
    key = "SERVICE_ID"
    value = "backend-2"
  }
  
  env {
    key = "SERVICE_CONFIG"
    value = "/files/backend_2.hcl"
  }
  
  env {
    key = "CONSUL_HTTP_ADDR"
    value = "consul-1.container.shipyard.run:8500"
  }
  
  env {
    key = "CONSUL_GRPC_ADDR"
    value = "consul-1.container.shipyard.run:8502"
  }
  
  volume {
    source      = "./files"
    destination = "/files"
  }
}