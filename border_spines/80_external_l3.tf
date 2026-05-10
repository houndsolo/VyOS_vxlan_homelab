resource "vyos_vrf_name_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
  depends_on = [vyos_vrf_name.create_vrfs]
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

resource "vyos_interfaces_ethernet" "set_eth3_mtu" {
  identifier = { ethernet = "eth3" }
  description = "FW-WAN connectivity"
  mtu = "9169"
  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}

resource "vyos_interfaces_ethernet_vif" "set_eth3_vif_mtu" {
  depends_on = [resource.vyos_interfaces_ethernet.set_eth3_mtu]
  for_each = var.vnis.l3
  description = "${each.value.vrf} L3 external connectivity"
  identifier = {
    ethernet = "eth3"
    vif = each.value.ext_l3_vlan
  }
  vrf = each.value.vrf
  mtu = "9169"
}


resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth3" {
  for_each = var.vnis.l3
  depends_on = [vyos_interfaces_ethernet_vif.set_eth3_vif_mtu]
  identifier = { interface = "eth3.${each.value.ext_l3_vlan}" }
}

