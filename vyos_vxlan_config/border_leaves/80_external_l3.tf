resource "vyos_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
  depends_on = [vyos_vrf_name.create_vrfs]
  identifier = { peer_group = "FW_L3_out" }
  capability = {
    dynamic          = true
    extended_nexthop = true
  }
  remote_as     = local.ext_l3_asn
  ebgp_multihop = 20
  update_source = "dum240"
  address_family = {
    ipv4_vpn = {
      soft_reconfiguration = { inbound = true }
    }
  }
}

resource "vyos_protocols_bgp_neighbor" "fw_wan_conectivity" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_FW_l3_out]
  identifier = { neighbor = local.l3ext_peering_address_remote }
  peer_group = "FW_L3_out"
}


resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines_switch1]
  for_each   = var.fabric.spines
  address    = ["10.251.${each.value.id}${var.node.id}.1/31"]

  identifier = {
    ethernet = "eth1"
    vif      = 1000 + 100 * each.value.id + var.node.id
  }
  description = "mpls ldp ipv4 link"
  mtu         = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch2" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines_switch2]
  for_each   = var.fabric.spines
  address    = ["10.252.${each.value.id}${var.node.id}.1/31"]

  identifier = {
    ethernet = "eth2"
    vif      = 2000 + 100 * each.value.id + var.node.id
  }
  description = "mpls ldp ipv4 link"
  mtu         = "9169"

}

