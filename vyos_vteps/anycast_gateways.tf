resource "vyos_vrf_name" "create_vrfs" {
  for_each = var.vrfs
  identifier = { name = each.key }
  table = each.value.table
}

resource "vyos_interfaces_bridge_vif" "br0_vif_anycast_gateways" {
  depends_on = [vyos_interfaces_bridge_member_interface.br0_eth3]
  for_each = var.vnis
  identifier = {
    bridge = "br0"
    vif = each.value.vlan_id
  }
  address = [
    "${each.value.anycast_gw_ip}/${each.value.anycast_gw_cidr}"
  ]
  mac = each.value.anycast_mac
  vrf = each.value.vrf
}
