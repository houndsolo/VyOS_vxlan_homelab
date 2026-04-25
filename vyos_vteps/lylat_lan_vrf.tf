resource "vyos_vrf_name" "lylat_lan" {
  identifier = { name = "lylat_lan" }
  table = 1337
}

resource "vyos_interfaces_bridge_vif" "br0_vif_9009_anycast_gateway" {
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  identifier = {
    bridge = "br0"
    vif = 9
  }
  address = [
    "10.9.0.5/16"
  ]
  mac = "0e:00:00:10:00:09"
  vrf = "lylat_lan"
}




resource "vyos_interfaces_bridge_vif" "br0_vif_9090_anycast_gateway" {
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  identifier = {
    bridge = "br0"
    vif = 90
  }
  address = [
    "10.90.0.5/16"
  ]
  mac = "0e:00:00:10:00:90"
  vrf = "lylat_lan"
}
