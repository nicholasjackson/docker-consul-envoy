# Docker image containing Consul and Envoy

Docker image containing Consul and Envoy which can also register services and central config when starting.

Can be used for registering services or config, or when you need an Envoy sidecar.

## Usage
```
docker run --rm \
  -e "CONSUL_HTTP_ADDR=10.5.0.2:8500" \
  -e "CONSUL_GRPC_ADDR=10.5.0.2:8502" \
  -e "SERVICE_CONFIG=/config/web.json" \
  -v $(pwd)/service_config:/config \
  nicholasjackson/consul-envoy:v1.6.0-v0.10.0 \
  bash -c "consul connect envoy -sidecar-for web-v1"
```

## Environment variables

### CONSUL_HTTP_ADDR - HTTP address for the Consul agent

### CONSUL_GRPC_ADDR - HTTP address for the Consul agent GRPC API, used by Envoy

### SERVICE_CONFIG - path to Consul service config file
When the container starts a service config specified in the environment variable will be registered with Consul, when the container
exits the service will be de-registered.

### CENTRAL_CONFIG - ; separated list of central config files
When the container starts any central config file referenced in the environment variable will automatically be registered
with Consul. On exit this configuration is not removed.

### CENTRAL_CONFIG_DIR - directory location containing central config
When the container starts all central config in the folder referenced by the environment variable will automatically be 
registered with Consul. On ext this configuration is not removed.

## Example of using this container with a Kubernetes job to load central config

### Terraform
```
resource "kubernetes_config_map" "central_config" {
  metadata {
    name = "central-config"
  }

  data = {
    "pong-aks-defaults.hcl" = file("${path.module}/consul_config/pong-aks-defaults.hcl")
    "pong-vms-defaults.hcl" = file("${path.module}/consul_config/pong-vms-defaults.hcl")
    "pong-aks-resolver.hcl" = file("${path.module}/consul_config/pong-aks-resolver.hcl")
    "pong-vms-resolver.hcl" = file("${path.module}/consul_config/pong-vms-resolver.hcl")
  }
}

resource "kubernetes_job" "central_config" {
  depends_on = [helm_release.consul]

  metadata {
    name = "central-config"
  }

  spec {
    template {
      metadata {
        labels = {
          version = "v0.0.1"
        }
      }
      spec{
        volume {
          name = kubernetes_config_map.central_config.metadata[0].name
        
          config_map {
            name = kubernetes_config_map.central_config.metadata[0].name
          }
        }

        container {
          image = "nicholasjackson/consul-envoy:v1.6.0-v0.10.0"
      		name = "central-config"

          env {
            name  = "CONSUL_HTTP_ADDR"
            value = "consul-consul-server:8500"
          }

          env {
            name  = "CONSUL_GRPC_ADDR"
            value = "consul-consul-server:8502"
          }

          env {
            name  = "CENTRAL_CONFIG_DIR"
            value = "/config"
          }
          
      		volume_mount {
          	read_only = true  
            mount_path = "/config"
            name = kubernetes_config_map.central_config.metadata[0].name
      		}
        }
      }
    }
  }
}
```

### YAML

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: central-config-split
data:
  1_web_defaults.yml: |
    kind = "service-defaults"
    name = "web"
    protocol = "http"
  2_api_defaults.yml: |
    kind = "service-defaults"
    name = "api"
    protocol = "http"
  3_api_resolver.yml: |
    kind = "service-resolver"
    name = "api"

    # https://www.consul.io/api/health.html#filtering-2
    # # Show Node.Meta demonstration showing performance testing a new instance type
    default_subset = "v1"

    subsets = {
      v1 = {
        filter = "Service.Meta.version == 1"
      }
      v2 = {
        filter = "Service.Meta.version == 2"
      }
    }

---
apiVersion: batch/v1
kind: Job
metadata:
  name: central-config-split
  labels:
    app: central-config-split
spec:
  template:
    spec:
      restartPolicy: Never
      volumes:
      - name: central-config
        configMap:
          name: central-config-split
      containers:
      - name: central-config-split
        image: "nicholasjackson/consul-envoy:v1.6.0-v0.10.0"
        env:
        - name: "CONSUL_HTTP_ADDR"
          value: "consul-consul-server:8500"
        - name: "CONSUL_GRPC_ADDR"
          value: "consul-consul-server:8502"
        - name: "CENTRAL_CONFIG_DIR"
          value: "/config"
        volumeMounts:
        - name: "central-config"
          readOnly: true
          mountPath: "/config"
```
