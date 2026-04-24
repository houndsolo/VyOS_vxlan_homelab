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
resource "vyos_protocols_bgp_peer_group" "peer_group_leaf_underlay" {
  identifier = {peer_group = "leaf_underlay"}
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

resource "vyos_protocols_bgp_peer_group" "peer_group_leaf_overlay" {
  identifier = {peer_group = "leaf_overlay"}
  capability = {
    dynamic = true
    extended_nexthop = true
  }
  remote_as = local.vxlan_local_as
  update_source = local.vxlan_source_interface
  address_family = {
    l2vpn_evpn = {
      soft_reconfiguration = {inbound = true}
    }
  }
}

resource "vyos_protocols_bgp_peer_group_local_as" "peer_group_leaf_local_as" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_overlay]
  identifier = {
    local_as = local.vxlan_local_as
    peer_group = "leaf_overlay"
  }
}


resource "vyos_protocols_bgp_neighbor" "bgp_neighbors_sw1" {
  for_each      = var.leaves
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_underlay]
  identifier = { neighbor = "eth1.${1000+100*var.node.id+each.value.id}" }
  interface = {
    v6only = {
      peer_group = "leaf_underlay"
    }
  }
}

resource "vyos_protocols_bgp_neighbor" "bgp_neighbors_sw2" {
  for_each      = var.leaves
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_underlay]
  identifier = { neighbor = "eth2.${2000+100*var.node.id+each.value.id}" }
  interface = {
    v6only = {
      peer_group = "leaf_underlay"
    }
  }
}

#
#resource "vyos_protocols_bgp_address_family_l2vpn_evpn_vni" "vni_6" {
#  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
#  identifier = { vni = 9006 }
#  #advertise_default_gw = true
#  advertise_svi_ip     = var.bgp_l2vpn_vni_advertise_svi
#}
#

resource "vyos_protocols_bgp_address_family_ipv4_unicast_network" "redistribute_loopback" {
  identifier = { network = local.vxlan_loopback }
}

resource "vyos_protocols_bgp_neighbor" "vxlan_peering" {
  for_each      = var.leaves
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_overlay]
  identifier = { neighbor = "10.255.240.${each.value.id}"}
  peer_group = "leaf_overlay"
}
