resource "vyos_interfaces_ethernet" "ext_l3" {
  identifier  = { ethernet = "eth3" }
  description = "ext_l3"
  mtu         = "9189"

  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}


resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth3" {
  depends_on = [vyos_interfaces_ethernet.ext_l3]
  identifier = { interface = "eth3" }
}

resource "vyos_protocols_bgp_peer_group" "peer_group_FW_l3_out_v6" {
  depends_on = [vyos_vrf_name.create_vrfs]
  identifier = { peer_group = "FW_L3_out_v6" }
  capability = {
    dynamic          = true
    extended_nexthop = true
  }
  remote_as     = local.ext_l3_asn
  ebgp_multihop = 20
  update_source = "dum240"
  address_family = {
    ipv4_unicast = {
      soft_reconfiguration = { inbound = true }
    }
    #ipv6_unicast = {
    #  soft_reconfiguration = { inbound = true }
    #}
  }
}

resource "vyos_protocols_bgp_address_family_ipv4_unicast_redistribute_connected" "redistribute_connected" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
}

resource "vyos_protocols_bgp_neighbor" "ext_l3" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = { neighbor = "eth3" }
  interface = {
    v6only = {
      peer_group = "FW_L3_out_v6"
    }
  }
}

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

