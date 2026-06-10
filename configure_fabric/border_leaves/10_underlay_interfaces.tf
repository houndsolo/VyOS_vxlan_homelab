resource "vyos_interfaces_dummy" "dummy_interface" {
  identifier = { dummy = local.vxlan_source_interface }
  address = [
    local.vxlan_loopback,
    #local.mpls_v6_loopback
  ]
  mtu = "9169"
}

resource "vyos_interfaces_ethernet" "link_to_spines_switch1" {
  identifier  = { ethernet = "eth1" }
  description = "p2p-sw1"
  mtu         = "9169"

  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}

resource "vyos_interfaces_ethernet_vif" "link_to_spines_vifs_switch1" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines_switch1]
  for_each   = var.fabric.spines

  identifier = {
    ethernet = "eth1"
    vif      = 1000 + 100 * each.value.id + var.node.id
  }
  address    = ["10.251.${each.value.id}${var.node.id}.1/31"]
  ipv6        = {}
  description = "mpls ldp ipv4 link"
  mtu         = "9169"

}

resource "vyos_interfaces_ethernet" "link_to_spines_switch2" {
  identifier  = { ethernet = "eth2" }
  description = "p2p-sw2"
  mtu         = "9169"
  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}

resource "vyos_interfaces_ethernet_vif" "link_to_spines_vifs_switch2" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines_switch2]
  for_each   = var.fabric.spines

  identifier = {
    ethernet = "eth2"
    vif      = 2000 + 100 * each.value.id + var.node.id
  }
  address    = ["10.252.${each.value.id}${var.node.id}.1/31"]
  ipv6        = {}
  description = "mpls ldp ipv4 link"
  mtu         = "9169"

}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth1" {
  depends_on = [vyos_interfaces_ethernet_vif.link_to_spines_vifs_switch1]
  for_each   = var.fabric.spines
  identifier = { interface = "eth1.${1000 + 100 * each.value.id + var.node.id}" }
}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth2" {
  depends_on = [vyos_interfaces_ethernet_vif.link_to_spines_vifs_switch2]
  for_each   = var.fabric.spines
  identifier = { interface = "eth2.${2000 + 100 * each.value.id + var.node.id}" }
}
