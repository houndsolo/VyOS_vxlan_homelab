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


