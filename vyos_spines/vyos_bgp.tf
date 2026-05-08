resource "vyos_protocols_bgp" "enable_bgp" {
  system_as = local.bgp_system_as
}

resource "vyos_protocols_bgp_parameters" "set_router_id" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  router_id = local.vxlan_loopback_net
  fast_convergence = true
}

resource "vyos_protocols_bgp_parameters_bestpath_as_path" "bgp_multipath_relax" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  multipath_relax = true
}

resource "vyos_protocols_bgp_address_family_l2vpn_evpn" "l2vpn_evpn_config" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
  advertise_all_vni = var.bgp_l2vpn_advertise_vni
  advertise_svi_ip = false
  rt_auto_derive = var.rt_auto_derive
}

resource "vyos_protocols_bgp_address_family_l2vpn_evpn_flooding" "l2vpn_evpn_flooding" {
  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
  disable = var.bgp_l2vpn_flooding_disable
  head_end_replication = var.bgp_l2vpn_her
}


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
  remote_as = "internal"
  update_source = local.vxlan_source_interface
  address_family = {
    l2vpn_evpn = {
      soft_reconfiguration = {inbound = true}
      route_reflector_client = true
    }
  }
}

resource "vyos_protocols_bgp_peer_group_local_as" "peer_group_underlay_local_as" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_overlay]
  identifier = {
    local_as = local.underlay_local_as
    peer_group = "leaf_underlay"
  }
  no_prepend = { replace_as = true }
}


resource "vyos_protocols_bgp_neighbor" "bgp_neighbors_sw1" {
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_underlay]
  identifier = { neighbor = "eth1.${1000+100*var.node.id+each.value.id}" }
  interface = {
    v6only = {
      peer_group = "leaf_underlay"
    }
  }
}

resource "vyos_protocols_bgp_neighbor" "bgp_neighbors_sw2" {
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_underlay]
  identifier = { neighbor = "eth2.${2000+100*var.node.id+each.value.id}" }
  interface = {
    v6only = {
      peer_group = "leaf_underlay"
    }
  }
}

resource "vyos_protocols_bgp_address_family_ipv4_unicast_network" "redistribute_loopback" {
  identifier = { network = local.vxlan_loopback }
}

resource "vyos_protocols_bgp_neighbor" "vxlan_peering" {
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_leaf_overlay]
  identifier = { neighbor = "10.255.240.${each.value.id}"}
  peer_group = "leaf_overlay"
}


resource "vyos_vrf_name_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
  depends_on = [
    vyos_vrf_name.create_vrfs,
  ]
  for_each = var.vnis.l3
  identifier = {
    peer_group = "FW_L3_out"
    name = each.value.vrf
  }
  capability = {
    dynamic = true
    extended_nexthop = true
  }
  remote_as = local.ext_l3_asn
  address_family = {
    ipv4_unicast = {
      soft_reconfiguration = {inbound = true}
    }
  }
}

resource "vyos_vrf_name_protocols_bgp_neighbor" "fw_wan_conectivity" {
  depends_on = [vyos_vrf_name_protocols_bgp_peer_group.peer_group_FW_l3_out]
  for_each = var.vnis.l3
  identifier = {
    name = each.value.vrf
    neighbor = "eth3.${each.value.ext_l3_vlan}"
  }
  interface = {
    v6only = {
      peer_group = "FW_L3_out"
    }
  }
}
