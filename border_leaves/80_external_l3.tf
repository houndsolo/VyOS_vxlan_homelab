resource "vyos_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
  depends_on = [vyos_vrf_name.create_vrfs]
  identifier = { peer_group = "FW_L3_out" }
  capability = {
    dynamic = true
    extended_nexthop = true
  }
  remote_as = local.ext_l3_asn
  ebgp_multihop = 20
  update_source = "dum240"
  address_family = {
    ipv4_vpn = {
      soft_reconfiguration = {inbound = true}
    }
  }
}

resource "vyos_protocols_bgp_neighbor" "fw_wan_conectivity" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_FW_l3_out]
  identifier = { neighbor = local.l3ext_peering_address_remote }
  peer_group = "FW_L3_out"
}


resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1" {
  for_each =  var.fabric.spines
  address = ["10.251.${each.value.id}${var.node.id}.1/31"]

  identifier = {
    ethernet = "eth1"
    vif = 3000 + 100 *   each.value.id + var.node.id
  }
  description = "mpls ldp ipv4 link"
  mtu = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch2" {
  for_each =  var.fabric.spines
  address = ["10.252.${each.value.id}${var.node.id}.1/31"]

  identifier = {
    ethernet = "eth2"
    vif = 3000 + 100 *   each.value.id + var.node.id
  }
  description = "mpls ldp ipv4 link"
  mtu = "9169"

}

resource "vyos_protocols_bgp_neighbor" "bgp_underlay_neighbors_sw1_border_ldp" {
  for_each = var.fabric.spines
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = { neighbor = "10.251.${each.value.id}${var.node.id}.0" }
  peer_group = "spine_underlay_mpls"
}

resource "vyos_protocols_bgp_neighbor" "bgp_underlay_neighbors_sw2_border_ldp" {
  for_each = var.fabric.spines
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = { neighbor = "10.252.${each.value.id}${var.node.id}.0" }
  peer_group = "spine_underlay_mpls"
}

resource "vyos_policy_prefix_list" "create_prefix_list_mpls_ipv4" {
  identifier = {
    prefix_list = "mpls_ipv4_export"
  }
}

resource "vyos_policy_prefix_list_rule" "ipv4_export_prefix_rules_mpls_ipv4" {
  depends_on = [resource.vyos_policy_prefix_list.create_prefix_list_mpls_ipv4]

  identifier = {
    prefix_list = "mpls_ipv4_export"
    rule        = 10
  }

  action = "permit"
  prefix = "10.255.230.0/24"
  ge = 32
}

resource "vyos_policy_route_map" "create_route_map_mpls_ipv4" {
  identifier = {
    route_map = "mpls_ipv4_export_rm"
  }
}

resource "vyos_policy_route_map_rule" "ipv4_vpn_export_permit_mpls_ipv4" {
  depends_on = [resource.vyos_policy_route_map.create_route_map_mpls_ipv4]

  identifier = {
    route_map = "mpls_ipv4_export_rm"
    rule      = 10
  }

  action = "permit"

  match = {
    ip = {
      address = {
        prefix_list = "mpls_ipv4_export"
      }
    }
  }
}

