resource "vyos_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
  depends_on = [vyos_vrf_name.create_vrfs]
  identifier = { peer_group = "FW_L3_out" }
  capability = {
    dynamic = true
    extended_nexthop = true
  }
  remote_as = local.ext_l3_asn
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


#resource "vyos_interfaces_dummy" "set_dum_ext" {
#  identifier = { dummy = "dum420" }
#  description = "FW-WAN VPNv4 peering"
#  address = local.l3ext_peering_address_local
#  mtu = "9169"
#}
