resource "vyos_interfaces_vxlan" "vxlan_interfaces_L3" {
  depends_on       = [vyos_vrf_name.create_vrfs]
  for_each         = var.vnis.l3
  identifier       = { vxlan = "vxlan${each.value.vni}" }
  source_interface = local.vxlan_source_interface
  mtu              = var.vxlan.mtu
  ip = {
    disable_arp_filter        = var.vxlan.disable_arp_filter
    disable_forwarding        = var.vxlan.disable_forwarding
    enable_arp_accept         = var.vxlan.enable_arp_accept
    enable_arp_announce       = var.vxlan.enable_arp_announce
    enable_directed_broadcast = var.vxlan.enable_directed_broadcast
    enable_proxy_arp          = var.vxlan.enable_proxy_arp
    proxy_arp_pvlan           = var.vxlan.proxy_arp_pvlan
  }
  ipv6 = {
    disable_forwarding = true
  }
  parameters = {
    external          = var.vxlan.external
    neighbor_suppress = var.vxlan.neighbor_suppress
    nolearning        = var.vxlan.nolearning
    vni_filter        = var.vxlan.vni_filter
  }
  vni = each.value.vni
}


