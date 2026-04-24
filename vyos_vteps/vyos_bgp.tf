resource "vyos_protocols_bgp" "enable_bgp" {
  depends_on = [
    #vyos_protocols_bfd_peer.spine_bfd_peers,
    vyos_interfaces_ethernet.link_to_vms
  ]
  system_as = local.bgp_system_as
}
#
#resource "vyos_protocols_bgp_address_family_ipv4_unicast_maximum_paths" "bgp_multipath" {
#  depends_on = [vyos_protocols_bgp.enable_bgp]
#  ibgp = 4
#}
#
#resource "vyos_protocols_bgp_address_family_l2vpn_evpn" "l2vpn_evpn_config" {
#  depends_on = [vyos_protocols_bgp.enable_bgp]
#  advertise_all_vni = var.bgp_l2vpn_advertise_vni
#  advertise_svi_ip = var.bgp_l2vpn_advertise_svi
#  rt_auto_derive = false
#}
#
#resource "vyos_protocols_bgp_address_family_l2vpn_evpn_flooding" "l2vpn_evpn_flooding" {
#  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
#  disable = var.bgp_l2vpn_flooding_disable
#  head_end_replication = var.bgp_l2vpn_her
#}
#
resource "vyos_protocols_bgp_peer_group" "peer_group_spine_underlay" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  identifier = {peer_group = "spine_underlay"}
  capability = {
    dynamic = true
    extended_nexthop = true
  }
  remote_as = "external"
  address_family = {
    ipv4_unicast = {
      soft_reconfiguration = {inbound = true}
    }
  }
}

resource "vyos_protocols_bgp_peer_group" "peer_group_spine_overlay" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  identifier = {peer_group = "spine_overlay"}
  capability = {
    dynamic = true
    extended_nexthop = true
  }
  remote_as = local.vxlan_local_as
  address_family = {
    l2vpn_evpn = {
      soft_reconfiguration = {inbound = true}
    }
  }
}

resource "vyos_protocols_bgp_peer_group_local_as" "peer_group_spine_local_as" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = {
    local_as = local.vxlan_local_as
    peer_group = "spine_overlay"
  }
}

resource "vyos_protocols_bgp_neighbor" "bgp_neighbors_sw1" {
  for_each      = var.spines
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = { neighbor = "10.241.${100*each.value.id+var.node.id}.0" }
  peer_group = "spine_underlay"
}

resource "vyos_protocols_bgp_neighbor" "bgp_neighbors_sw2" {
  for_each      = var.spines
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = { neighbor = "10.242.${100*each.value.id+var.node.id}.0" }
  peer_group = "spine_underlay"
}

#
#resource "vyos_protocols_bgp_address_family_l2vpn_evpn_vni" "vni_6" {
#  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
#  identifier = { vni = 9006 }
#  #advertise_default_gw = true
#  advertise_svi_ip     = var.bgp_l2vpn_vni_advertise_svi
#}
#

