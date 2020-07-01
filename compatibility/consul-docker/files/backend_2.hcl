service {
  name = "backend"
  id = "backend-2"
  port = 9090
  tags = ["v2"]
  address = "10.5.0.202"

  connect { 
    sidecar_service { 
      port = 20001

      check {
        name = "Connect Sidecar Listening"
        tcp = "10.5.0.202:20001"
        interval = "10s"
      }
      
      proxy {}
    }
  }
}