service {
  name = "backend"
  id = "backend-1"
  port = 9090
  tags = ["v1"]
  address = "10.5.0.201"

  connect { 
    sidecar_service { 
      port = 20001

      check {
        name = "Connect Sidecar Listening"
        tcp = "10.5.0.201:20001"
        interval = "10s"
      }

      proxy {}
    }
  }
}