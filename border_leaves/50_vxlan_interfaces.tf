resource "vyos_interfaces_vxlan" "vxlan_interfaces_L2" {
  depends_on = [vyos_protocols_bgp_neighbor.bgp_underlay_neighbors_sw2]
  for_each = local.l2_vnis
  identifier = { vxlan = "vxlan${each.value.vni}" }
  source_interface = local.vxlan_source_interface
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
    external = false
    neighbor_suppress = var.vxlan_neighbor_suppress
    nolearning = var.vxlan_nolearning
    vni_filter = var.vxlan_vni_filter
  }
  vni = each.value.vni
}

resource "vyos_interfaces_vxlan" "vxlan_interfaces_L3" {
  depends_on = [vyos_vrf_name.create_vrfs]
  for_each = var.vnis.l3
  identifier = { vxlan = "vxlan${each.value.vni}" }
  description = "Layer 3 for ${each.value.vrf} vrf"
  source_interface = local.vxlan_source_interface
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
    external = false
    neighbor_suppress = var.vxlan_neighbor_suppress
    nolearning = var.vxlan_nolearning
    vni_filter = var.vxlan_vni_filter
  }
  vni = each.value.vni
}
