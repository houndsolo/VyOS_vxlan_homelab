resource "vyos_interfaces_dummy" "dummy_interface" {
  identifier = { dummy = local.vxlan_source_interface }
  address = [
    local.vxlan_loopback,
    local.vxlan_loopback_v6,
    local.mpls_v6_loopback
  ]
  mtu = "9169"
}

resource "vyos_interfaces_ethernet" "set_eth1_mtu" {
  identifier  = { ethernet = "eth1" }
  description = "switch-1 connectivity"
  mtu         = "9169"
  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}

resource "vyos_interfaces_ethernet" "set_eth2_mtu" {
  identifier  = { ethernet = "eth2" }
  description = "switch-2 connectivity"
  mtu         = "9169"
  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}


resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1" {
  depends_on = [vyos_interfaces_ethernet.set_eth1_mtu]
  for_each   = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.fabric_ext_leaves)

  identifier = {
    ethernet = "eth1"
    vif      = 1000 + 100 * var.node.id + each.value.id
  }
  ipv6        = {}
  description = "p2p-leaf-${each.value.id} - vlan${1000 + 100 * var.node.id + each.value.id}-sw1"
  mtu         = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch2" {
  depends_on = [vyos_interfaces_ethernet.set_eth2_mtu]
  for_each   = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.fabric_ext_leaves)

  identifier = {
    ethernet = "eth2"
    vif      = 2000 + 100 * var.node.id + each.value.id
  }
  ipv6        = {}
  description = "p2p-leaf-${each.value.id} - vlan${2000 + 100 * var.node.id + each.value.id}-sw2"
  mtu         = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1_ldp" {
  depends_on = [vyos_interfaces_ethernet.set_eth1_mtu]
  for_each   = var.fabric.border_leaves
  address    = ["10.251.${var.node.id}${each.value.id}.0/31"]

  identifier = {
    ethernet = "eth1"
    vif      = 1000 + 100 * var.node.id + each.value.id
  }
  ipv6 = {}
  description = "mpls ldp ipv4 link"
  mtu         = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch2_ldp" {
  depends_on = [vyos_interfaces_ethernet.set_eth2_mtu]
  for_each   = var.fabric.border_leaves
  address    = ["10.252.${var.node.id}${each.value.id}.0/31"]

  identifier = {
    ethernet = "eth2"
    vif      = 2000 + 100 * var.node.id + each.value.id
  }
  ipv6 = {}
  description = "mpls ldp ipv4 link"
  mtu         = "9169"

}


resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth1" {
  depends_on = [
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch1,
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch1_ldp
  ]
  for_each   = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves, var.fabric.fabric_ext_leaves)
  identifier = { interface = "eth1.${1000 + 100 * var.node.id + each.value.id}" }
}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth2" {
  depends_on = [
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch2,
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch2_ldp
  ]
  for_each   = merge(var.fabric.leaves, var.fabric.leaves_greatfox, var.fabric.border_leaves, var.fabric.fabric_ext_leaves)
  identifier = { interface = "eth2.${2000 + 100 * var.node.id + each.value.id}" }
}

