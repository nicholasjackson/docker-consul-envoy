service {
  name = "api"
  id = "api-1"
  port = 9090
  tags = ["v1"]
  address = "10.5.0.200"


  connect { 
    sidecar_service {
      port = 20001

      check {
        name = "Connect Sidecar Listening"
        tcp = "10.5.0.200:20001"
        interval = "10s"
      }

      proxy {
        config {}

        upstreams {
          destination_name = "backend"
          local_bind_address = "127.0.0.1"
          local_bind_port = 9091
        }
      }
    }
  }
}