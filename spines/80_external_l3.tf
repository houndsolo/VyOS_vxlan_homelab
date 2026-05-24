resource "vyos_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
  identifier = {
    peer_group = "FW_L3_out"
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
    #ipv6_unicast = {
    #  soft_reconfiguration = {inbound = true}
    #}
  }
}

resource "vyos_protocols_bgp_neighbor" "fw_wan_conectivity" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_FW_l3_out]
  identifier = {
    neighbor = "10.250.${var.node.id}.0"
  }
  peer_group = "FW_L3_out"
}

resource "vyos_interfaces_ethernet" "set_eth3_mtu" {
  identifier = { ethernet = "eth3" }
  description = "FW-WAN connectivity"
  mtu = "9169"
  address = ["10.250.${var.node.id}.1/31"]
  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}


resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth3" {
  for_each = var.vnis.l3
  identifier = { interface = "eth3" }
}


resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1_ldp" {
  depends_on = [vyos_interfaces_ethernet.set_eth1_mtu]
  for_each =  var.fabric.border_leaves
  address = ["10.251.${var.node.id}${each.value.id}.0/31"]

  identifier = {
    ethernet = "eth1"
    vif = 3000 + 100 * var.node.id + each.value.id
  }
  description = "mpls ldp ipv4 link"
  mtu = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch2_ldp" {
  depends_on = [vyos_interfaces_ethernet.set_eth2_mtu]
  for_each =  var.fabric.border_leaves
  address = ["10.252.${var.node.id}${each.value.id}.0/31"]

  identifier = {
    ethernet = "eth2"
    vif = 3000 + 100 * var.node.id + each.value.id
  }
  description = "mpls ldp ipv4 link"
  mtu = "9169"

}

resource "vyos_protocols_bgp_neighbor" "bgp_underlay_neighbors_sw1_border_ldp" {
  for_each = var.fabric.border_leaves
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_border_leaf_underlay_mpls]
  identifier = { neighbor = "10.251.${var.node.id}${each.value.id}.1" }
  peer_group = "border_leaf_underlay_mpls"
}

resource "vyos_protocols_bgp_neighbor" "bgp_underlay_neighbors_sw2_border_ldp" {
  for_each = var.fabric.border_leaves
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_border_leaf_underlay_mpls]
  identifier = { neighbor = "10.252.${var.node.id}${each.value.id}.1" }
  peer_group = "border_leaf_underlay_mpls"
}

resource "vyos_policy_prefix_list" "create_prefix_list_block_fw_wan" {
  identifier = {
    prefix_list = "ipv4_block_fw_WAN"
  }
}

resource "vyos_policy_prefix_list_rule" "ipv4_export_prefix_rules_block_fw_wan" {
  depends_on = [resource.vyos_policy_prefix_list.create_prefix_list_block_fw_wan]

  identifier = {
    prefix_list = "ipv4_block_fw_WAN"
    rule        = 10
  }

  action = "deny"
  prefix = "10.255.240.255/32"
}

resource "vyos_policy_prefix_list_rule" "ipv4_export_prefix_rest" {
  depends_on = [resource.vyos_policy_prefix_list.create_prefix_list_block_fw_wan]

  identifier = {
    prefix_list = "ipv4_block_fw_WAN"
    rule        = 20
  }

  action = "permit"
  prefix = "10.255.240.0/24"
  ge = 32
}

resource "vyos_policy_route_map" "create_route_map_block_fw_wan" {
  identifier = {
    route_map = "ipv4_block_fw_WAN_rm"
  }
}

resource "vyos_policy_route_map_rule" "ipv4_vpn_export_permit_block_fw_wan" {
  depends_on = [resource.vyos_policy_route_map.create_route_map_block_fw_wan]

  identifier = {
    route_map = "ipv4_block_fw_WAN_rm"
    rule      = 10
  }

  action = "permit"

  match = {
    ip = {
      address = {
        prefix_list = "ipv4_block_fw_WAN"
      }
    }
  }
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

resource "vyos_policy_prefix_list_rule" "ipv4_export_prefix_rules_mpls_ipv4_2" {
  depends_on = [resource.vyos_policy_prefix_list.create_prefix_list_mpls_ipv4]

  identifier = {
    prefix_list = "mpls_ipv4_export"
    rule        = 20
  }

  action = "permit"
  prefix = "10.250.0.0/16"
  ge = 31
  le = 31
}


resource "vyos_policy_route_map" "create_route_map_mpls_ipv4" {
  identifier = {
    route_map = "mpls_ipv4_export_rm"
  }
}

resource "vyos_policy_route_map_rule" "ipv4_vpn_export_permit_mpls_ipv4" {
  depends_on = [resource.vyos_policy_route_map.create_route_map_block_fw_wan]

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

