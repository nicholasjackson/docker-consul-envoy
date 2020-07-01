container "consul_1" {
  image {
    name = "consul:${env("CONSUL_VERSION")}"
  }
  
  command = ["consul", "agent", "-config-file=/config/consul.hcl"]

  volume {
    source      = "./consul_config"
    destination = "/config"
  }

  network { 
    name = "network.onprem"
  }
  
  port {
    local  = "8500"
    remote = "8500"
    host   = "8500"
  }
}