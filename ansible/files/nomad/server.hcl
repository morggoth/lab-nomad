server {
  enabled = true
  bootstrap_expect = 2
}

consul {
  address             = "127.0.0.1:8500"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true
}

bind_addr = "127.0.0.1"

advertise {
  http = "local_addr"
}

client {
  enabled = true
}