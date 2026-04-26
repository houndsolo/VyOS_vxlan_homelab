#resource "vyos_protocols_bgp_address_family_l2vpn_evpn_vni" "vni_profile_1" {
#  for_each = var.vnis
#  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
#  identifier = { vni = each.value.vni }
#  rd = "${local.vxlan_loopback_net}:${tostring(each.value.vni)}"
#  advertise_default_gw = each.value.advertise_default_gw
#  advertise_svi_ip     = each.value.advertise_svi_ip
#}
#
#
#resource "vyos_interfaces_vxlan" "svd_vxlan_intf" {
#  depends_on = [vyos_protocols_bgp_neighbor.bgp_neighbors_sw2]
#  identifier = { vxlan = "vxlan0" }
#  source_interface = local.vxlan_source_interface
#  mtu = var.vxlan_mtu
#  ip = {
#    disable_arp_filter = var.disable_arp_filter
#    disable_forwarding = var.disable_forwarding
#    enable_arp_accept = var.enable_arp_accept
#    enable_arp_announce = var.enable_arp_announce
#    enable_directed_broadcast = var.enable_directed_broadcast
#    enable_proxy_arp = var.enable_proxy_arp
#    proxy_arp_pvlan = var.proxy_arp_pvlan
#  }
#  ipv6 = {
#    disable_forwarding = true
#  }
#  parameters = {
#    external = var.vxlan_external
#    neighbor_suppress = var.vxlan_neighbor_suppress
#    nolearning = var.vxlan_nolearning
#    vni_filter = var.vxlan_vni_filter
#  }
#}
#
#resource "vyos_interfaces_vxlan_vlan_to_vni" "svd_vni_profile_1_mapping" {
#  #  depends_on = [vyos_interfaces_bridge_vif.br0_vif_2006_anycast_gateway]
#  for_each = var.vnis
#  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
#  identifier = {
#    #which vlan on local leaf
#    vlan_to_vni = tostring(each.value.vlan_id)
#    vxlan = "vxlan0"
#  }
#  #global vni
#  vni = each.value.vni
#}
#
#
#resource "vyos_interfaces_bridge" "vxlan_bridge" {
#  depends_on = [vyos_interfaces_vxlan.svd_vxlan_intf]
#  identifier = {bridge = "br0"}
#  enable_vlan = true
#  mtu = "9169"
#}
#
#resource "vyos_interfaces_bridge_member_interface" "br0_vxlan0" {
#  depends_on = [vyos_interfaces_bridge.vxlan_bridge]
#  identifier = {
#    bridge = "br0"
#    interface = "vxlan0"
#  }
#}
#
##resource "vyos_interfaces_bridge_member_interface" "br0_eth3" {
##  depends_on = [vyos_interfaces_bridge_member_interface.br0_vxlan0]
##  identifier = {
##    bridge = "br0"
##    interface = "eth3"
##  }
##  allowed_vlan = [
##    for vni in values(var.vnis) : tostring(vni.vlan_id)
##  ]
##}
