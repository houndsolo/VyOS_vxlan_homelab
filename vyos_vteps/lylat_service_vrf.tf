resource "vyos_vrf_name" "lylat_service" {
  identifier = { name = "lylat_service" }
  table = 1000
}


resource "vyos_interfaces_bridge" "vxlan_bridge" {
  depends_on = [vyos_interfaces_vxlan.svd_vxlan_intf]
  identifier = {bridge = "br0"}
  enable_vlan = true
  mtu = "9169"
}

resource "vyos_interfaces_bridge_member_interface" "br0_vxlan0" {
  depends_on = [vyos_interfaces_bridge.vxlan_bridge]
  identifier = {
    bridge = "br0"
    interface = "vxlan0"
  }
}

resource "vyos_interfaces_bridge_member_interface" "br0_eth3" {
  depends_on = [vyos_interfaces_bridge_member_interface.br0_vxlan0]
  identifier = {
    bridge = "br0"
    interface = "eth3"
  }
  allowed_vlan = [
    "6",
    "80",
  ]
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
