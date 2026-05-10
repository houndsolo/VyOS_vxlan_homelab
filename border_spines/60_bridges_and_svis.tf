resource "vyos_interfaces_bridge" "vxlan_bridge_L3" {
  for_each = var.vnis.l3
  depends_on = [vyos_interfaces_vxlan.vxlan_interfaces_L3]
  identifier = {bridge = "br${each.value.vni}"}
  mtu = "9169"
  vrf = each.value.vrf
}

resource "vyos_interfaces_bridge_member_interface" "br0_vxlan0" {
  for_each = var.vnis.l3
  depends_on = [vyos_interfaces_vxlan.vxlan_interfaces_L3]
  identifier = {
    bridge = "br${each.value.vni}"
    interface = "vxlan${each.value.vni}"
  }
}


