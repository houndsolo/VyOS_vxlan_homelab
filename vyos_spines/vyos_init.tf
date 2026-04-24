resource "vyos_system_ip_multipath" "set_multipath" {
  ignore_unreachable_nexthops = true
  layer4_hashing = true
}

resource "vyos_interfaces_dummy" "dummy_interface" {
  identifier = {dummy = local.vxlan_source_interface}
  address = [
    local.vxlan_loopback
  ]
  mtu = "9169"
}


resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1" {
  for_each = var.leaves

  identifier = {
    ethernet = "eth1"
    vif = 1000 + 100 * var.node.id + each.value.id
  }
  ipv6 = {}
  description = "p2p-leaf-${each.value.id} - vlan${1000 + 100 * var.node.id + each.value.id}-sw1"
  mtu = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_spines_vifs_switch2" {
  for_each = var.leaves

  identifier = {
    ethernet = "eth2"
    vif = 2000 + 100 * var.node.id + each.value.id
  }
  ipv6 = {}
  description = "p2p-leaf-${each.value.id} - vlan${2000 + 100 * var.node.id + each.value.id}-sw2"
  mtu = "9169"

}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth1" {
  for_each = var.leaves
  identifier = { interface = "eth1.${1000+100*var.node.id+each.value.id}" }
}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth2" {
  for_each = var.leaves
  identifier = { interface = "eth2.${2000+100*var.node.id+each.value.id}" }
}
