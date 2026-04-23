module "configure_vyos_vms" {
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  source = "./vyos_vteps"
  providers = { vyos = vyos.leaves[each.key] }
  host_node = each.value
  dns = var.dns
  leaves= var.leaves
  spines = var.spines
  rp_groups = var.rp_groups
  rp_group_ip_only = var.rp_group_ip_only
  anycast_rp_address = var.anycast_rp_address

  bgp_l2vpn_her = local.bgp_l2vpn_her
  bgp_l2vpn_flooding_disable = local.bgp_l2vpn_flooding_disable
  bgp_l2vpn_advertise_svi =  local.bgp_l2vpn_advertise_svi
  bgp_l2vpn_advertise_vni =  local.bgp_l2vpn_advertise_vni
  bgp_l2vpn_vni_advertise_svi =  local.bgp_l2vpn_vni_advertise_svi

  vxlan_mtu = local.vxlan_mtu
  disable_arp_filter = local.disable_arp_filter
  disable_forwarding = local.disable_forwarding
  enable_arp_accept = local.enable_arp_accept
  enable_arp_announce = local.enable_arp_announce
  enable_directed_broadcast = local.enable_directed_broadcast
  enable_proxy_arp = local.enable_proxy_arp
  proxy_arp_pvlan = local.proxy_arp_pvlan
  vxlan_external = local.vxlan_external
  vxlan_neighbor_suppress = local.vxlan_neighbor_suppress
  vxlan_nolearning = local.vxlan_nolearning
  vxlan_vni_filter = local.vxlan_vni_filter
}
