resource "vyos_interfaces_bridge" "vxlan_bridge_L3" {
  for_each = var.vnis.l3
  depends_on = [
    vyos_interfaces_vxlan.vxlan_interfaces_L2,
    vyos_interfaces_vxlan.vxlan_interfaces_L3
  ]
  identifier = {bridge = "br${each.value.vni}"}
  mtu = "9169"
  vrf = each.value.vrf
}

resource "vyos_interfaces_bridge" "vxlan_bridge_L2" {
  for_each = var.vnis.l2
  depends_on = [
    vyos_interfaces_vxlan.vxlan_interfaces_L2,
    vyos_interfaces_vxlan.vxlan_interfaces_L3
  ]
  identifier = {bridge = "br${each.value.vni}"}
  ip = {
    enable_arp_accept = true
  }
  mtu = "9169"
    address = [
      "${each.value.anycast_gw_ip}/${each.value.anycast_gw_cidr}"
    ]
    mac = each.value.anycast_mac
  vrf = each.value.vrf
}


resource "vyos_interfaces_bridge_member_interface" "br0_vxlan0" {
  depends_on = [
    vyos_interfaces_bridge.vxlan_bridge_L2,
    vyos_interfaces_bridge.vxlan_bridge_L3
  ]
  for_each = merge(var.vnis.l2,var.vnis.l3)
  #for_each = var.vnis.l2
  identifier = {
    bridge = "br${each.value.vni}"
    interface = "vxlan${each.value.vni}"
  }
}


