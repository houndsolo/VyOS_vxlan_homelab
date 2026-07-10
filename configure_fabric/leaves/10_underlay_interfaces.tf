resource "vyos_interfaces_dummy" "dummy_interface" {
  identifier = { dummy = var.node.vxlan_source_interface }
  address = [
    var.node.vxlan_loopback_v6
  ]
  mtu = var.vxlan.outer_mtu
}

resource "vyos_interfaces_ethernet" "link_to_spines" {
  for_each    = var.spines
  identifier  = { ethernet = each.value.uplink_if }
  description = "p2p-spine-${each.value.id}"
  mtu         = var.vxlan.outer_mtu

  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}


resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines]
  for_each   = var.spines
  identifier = { interface = each.value.uplink_if }
}
