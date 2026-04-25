resource "vyos_vrf_name" "lylat_service" {
  identifier = { name = "lylat_service" }
  table = 1000
}


resource "vyos_interfaces_bridge_vif" "br0_vif_9006_anycast_gateway" {
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  identifier = {
    bridge = "br0"
    vif = 6
  }
  address = [
    "10.6.0.5/16"
  ]
  mac = "0e:00:00:10:00:06"
  vrf = "lylat_service"
}




resource "vyos_interfaces_bridge_vif" "br0_vif_9080_anycast_gateway" {
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  identifier = {
    bridge = "br0"
    vif = 80
  }
  address = [
    "10.80.0.5/16"
  ]
  mac = "0e:00:00:10:00:80"
  vrf = "lylat_service"
}
