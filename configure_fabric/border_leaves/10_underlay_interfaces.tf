resource "vyos_interfaces_dummy" "dummy_interface" {
  identifier = { dummy = local.vxlan_source_interface }
  address = [
    local.vxlan_loopback,
    local.vxlan_loopback_v6
  ]
  mtu = "9189"
}

resource "vyos_interfaces_ethernet" "link_to_spines" {
  for_each   = var.fabric.spines
  identifier  = { ethernet = each.value.uplink_if }
  description = "p2p-spine-${each.value.id}"
  mtu         = "9189"

  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}


resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines]
  for_each   = var.fabric.spines
  identifier = { interface = each.value.uplink_if }
}
