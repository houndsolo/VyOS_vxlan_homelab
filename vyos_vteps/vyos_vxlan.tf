resource "vyos_interfaces_vxlan" "svd_vxlan_intf" {
  depends_on = [vyos_protocols_bgp_neighbor.bgp_neighbors_sw2]
  identifier = { vxlan = "vxlan0" }
  source_interface = local.vxlan_source_interface
  #group = var.rp_group_ip_only
  mtu = var.vxlan_mtu
  ip = {
    disable_arp_filter = var.disable_arp_filter
    disable_forwarding = var.disable_forwarding
    enable_arp_accept = var.enable_arp_accept
    enable_arp_announce = var.enable_arp_announce
    enable_directed_broadcast = var.enable_directed_broadcast
    enable_proxy_arp = var.enable_proxy_arp
    proxy_arp_pvlan = var.proxy_arp_pvlan
  }
  ipv6 = {
    disable_forwarding = true
  }
  parameters = {
    external = var.vxlan_external
    neighbor_suppress = var.vxlan_neighbor_suppress
    nolearning = var.vxlan_nolearning
    vni_filter = var.vxlan_vni_filter
  }
}

resource "vyos_interfaces_vxlan_vlan_to_vni" "svd_vni_6_mapping" {
  #  depends_on = [vyos_interfaces_bridge_vif.br0_vif_2006_anycast_gateway]
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  identifier = {
    #which vlan on local leaf
    vlan_to_vni = "6"
    vxlan = "vxlan0"
  }
  #global vni
  vni = 9006
}

resource "vyos_interfaces_vxlan_vlan_to_vni" "svd_vni_80_mapping" {
  #  depends_on = [vyos_interfaces_bridge_vif.br0_vif_2006_anycast_gateway]
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  identifier = {
    #which vlan on local leaf
    vlan_to_vni = "80"
    vxlan = "vxlan0"
  }
  #global vni
  vni = 9080
}

