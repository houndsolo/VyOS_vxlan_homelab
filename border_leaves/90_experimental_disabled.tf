#resource "vyos_interfaces_pseudo_ethernet" "anycast_gateway_peth" {
#  for_each = var.vnis.l2
#  depends_on = [vyos_interfaces_bridge_member_interface.br0_vxlan0]
#  identifier = { pseudo_ethernet = "peth${each.value.vni}" }
#  source_interface = "br${each.value.vni}"
#    ip = {
#      disable_arp_filter = true
#    }
#  address = [
#    #"${each.value.anycast_gw_ip}/${each.value.anycast_gw_cidr}"
#    "${each.value.anycast_gw_ip}/32"
#  ]
#  mac = each.value.anycast_mac
#  vrf = each.value.vrf
#}

#resource "vyos_interfaces_dummy" "anycast_dum_mac" {
#  for_each = var.vnis.l2
#  depends_on = [vyos_interfaces_bridge_member_interface.br0_vxlan0]
#  identifier = { dummy  = "dum${each.value.vni}" }
#  mac = each.value.anycast_mac
#}
#
#resource "vyos_interfaces_bridge_member_interface" "br0_dum0" {
#  depends_on = [
#    vyos_interfaces_bridge.vxlan_bridge_L2,
#    vyos_interfaces_bridge.vxlan_bridge_L3,
#    vyos_interfaces_dummy.anycast_dum_mac
#  ]
#  for_each = var.vnis.l2
#  identifier = {
#    bridge = "br${each.value.vni}"
#    interface = "dum${each.value.vni}"
#  }
#}
