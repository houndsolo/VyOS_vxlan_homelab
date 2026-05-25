resource "vyos_protocols_bgp" "enable_bgp" {
  depends_on = [
    #vyos_protocols_bfd_peer.spine_bfd_peers,
    #    vyos_interfaces_ethernet.link_to_vms,
    vyos_interfaces_dummy.dummy_interface
  ]
  system_as = local.bgp_system_as
}

resource "vyos_protocols_bgp_parameters" "set_router_id" {
  depends_on       = [vyos_protocols_bgp.enable_bgp]
  router_id        = local.vxlan_loopback_net
  fast_convergence = true
}

resource "vyos_protocols_bgp_parameters_bestpath_as_path" "bgp_multipath_relax" {
  depends_on      = [vyos_protocols_bgp.enable_bgp]
  multipath_relax = true
}

resource "vyos_protocols_bgp_peer_group" "peer_group_spine_underlay" {
  depends_on = [
    vyos_protocols_bgp.enable_bgp,
  ]
  identifier = { peer_group = "spine_underlay" }
  capability = {
    dynamic          = true
    extended_nexthop = true
  }
  remote_as = "external"
  address_family = {
    ipv4_unicast = {
      soft_reconfiguration = { inbound = true }
      route_map = {
        export = "local_as_rm"
      }
    }
  }
}

#resource "vyos_protocols_bgp_peer_group_local_as" "peer_group_underlay_local_as" {
#  depends_on = [
#  ]
#  identifier = {
#    local_as   = local.underlay_local_as
#    peer_group = "spine_underlay"
#  }
#  no_prepend = { replace_as = true }
#}
#
#resource "vyos_protocols_bgp_neighbor" "bgp_underlay_neighbors_sw1" {
#  for_each   = var.fabric.spines
#  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
#  identifier = { neighbor = "eth1.${1000 + 100 * each.value.id + var.node.id}" }
#  interface = {
#    v6only = {
#      peer_group = "spine_underlay"
#    }
#  }
#}
#
#resource "vyos_protocols_bgp_neighbor" "bgp_underlay_neighbors_sw2" {
#  for_each   = var.fabric.spines
#  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
#  identifier = { neighbor = "eth2.${2000 + 100 * each.value.id + var.node.id}" }
#  interface = {
#    v6only = {
#      peer_group = "spine_underlay"
#    }
#  }
#}
#
#resource "vyos_protocols_bgp_address_family_ipv4_unicast_network" "redistribute_loopback" {
#  depends_on = [vyos_protocols_bgp.enable_bgp]
#  identifier = { network = local.vxlan_loopback }
#}
