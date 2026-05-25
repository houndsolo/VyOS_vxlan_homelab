resource "vyos_protocols_bgp_address_family_l2vpn_evpn" "l2vpn_evpn_config" {
  depends_on        = [vyos_protocols_bgp.enable_bgp]
  advertise_all_vni = var.bgp_l2vpn.advertise_vni
  advertise_svi_ip  = false
  rt_auto_derive    = var.bgp_l2vpn.rt_auto_derive
}

resource "vyos_protocols_bgp_address_family_l2vpn_evpn_vni" "l2vni_bgp_global_config" {
  for_each             = local.l2_vnis
  depends_on           = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
  identifier           = { vni = each.value.vni }
  rd                   = "${local.vxlan_loopback_net}:${tostring(each.value.vni)}"
  advertise_default_gw = false
  advertise_svi_ip     = false
}


resource "vyos_protocols_bgp_address_family_l2vpn_evpn_flooding" "l2vpn_evpn_flooding" {
  depends_on           = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
  disable              = var.bgp_l2vpn.flooding_disable
  head_end_replication = var.bgp_l2vpn.her
}

resource "vyos_protocols_bgp_peer_group" "peer_group_leaf_overlay" {
  depends_on    = [vyos_protocols_bgp.enable_bgp]
  identifier    = { peer_group = "leaf_overlay" }
  remote_as     = "internal"
  update_source = local.vxlan_source_interface
  address_family = {
    l2vpn_evpn = {
      soft_reconfiguration   = { inbound = true }
      route_reflector_client = true
    }
  }
}

resource "vyos_protocols_bgp_neighbor" "vxlan_peering" {
  for_each   = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_overlay]
  identifier = { neighbor = "10.255.240.${each.value.id}" }
  peer_group = "leaf_overlay"
}
