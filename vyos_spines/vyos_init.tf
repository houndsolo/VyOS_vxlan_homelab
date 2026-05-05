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
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)

  identifier = {
    ethernet = "eth1"
    vif = 1000 + 100 * var.node.id + each.value.id
  }
  ipv6 = {}
  description = "p2p-leaf-${each.value.id} - vlan${1000 + 100 * var.node.id + each.value.id}-sw1"
  mtu = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_spines_vifs_switch2" {
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)

  identifier = {
    ethernet = "eth2"
    vif = 2000 + 100 * var.node.id + each.value.id
  }
  ipv6 = {}
  description = "p2p-leaf-${each.value.id} - vlan${2000 + 100 * var.node.id + each.value.id}-sw2"
  mtu = "9169"

}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth1" {
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)
  identifier = { interface = "eth1.${1000+100*var.node.id+each.value.id}" }
}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth2" {
  for_each = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves)
  identifier = { interface = "eth2.${2000+100*var.node.id+each.value.id}" }
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
