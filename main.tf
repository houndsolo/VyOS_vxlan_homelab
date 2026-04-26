module "configure_vyos_spines" {
  for_each = var.fabric.spines
  source = "./vyos_spines"
  providers = { vyos = vyos.spines[each.key] }
  node = each.value
  dns = var.dns
  fabric= var.fabric
}

module "configure_vyos_vms" {
  for_each = var.fabric.leaves
  source = "./vyos_vteps"
  providers = { vyos = vyos.leaves[each.key] }
  node = each.value
  dns = var.dns
  fabric= var.fabric

  bgp_l2vpn_her = local.bgp_l2vpn_her
  bgp_l2vpn_flooding_disable = local.bgp_l2vpn_flooding_disable
  bgp_l2vpn_advertise_svi =  local.bgp_l2vpn_advertise_svi
  bgp_l2vpn_advertise_vni =  local.bgp_l2vpn_advertise_vni
  rt_auto_derive = local.rt_auto_derive
  vnis = var.vnis
  vrfs = var.vrfs

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

module "configure_vyos_vms_greatfox" {
  for_each = var.fabric.leaves_greatfox
  source = "./vyos_vteps"
  providers = { vyos = vyos.greatfox }
  node = each.value
  dns = var.dns
  fabric= var.fabric

  bgp_l2vpn_her = local.bgp_l2vpn_her
  bgp_l2vpn_flooding_disable = local.bgp_l2vpn_flooding_disable
  bgp_l2vpn_advertise_svi =  local.bgp_l2vpn_advertise_svi
  bgp_l2vpn_advertise_vni =  local.bgp_l2vpn_advertise_vni
  rt_auto_derive = local.rt_auto_derive
  vnis = var.vnis
  vrfs = var.vrfs

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

module "configure_vyos_vms_border_vteps" {
  for_each = var.fabric.border_leaves
  source = "./vyos_border_vteps"
  providers = { vyos = vyos.border[each.key] }
  node = each.value
  dns = var.dns
  fabric= var.fabric

  bgp_l2vpn_her = local.bgp_l2vpn_her
  bgp_l2vpn_flooding_disable = local.bgp_l2vpn_flooding_disable
  bgp_l2vpn_advertise_svi =  local.bgp_l2vpn_advertise_svi
  bgp_l2vpn_advertise_vni =  local.bgp_l2vpn_advertise_vni
  rt_auto_derive = local.rt_auto_derive
  vnis = var.vnis
  vrfs = var.vrfs

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
