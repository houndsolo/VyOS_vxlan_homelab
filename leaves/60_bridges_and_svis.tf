resource "vyos_interfaces_bridge" "vxlan_bridge_L2" {
  depends_on = [
    vyos_interfaces_vxlan.vxlan_interfaces_L2,
  ]
  identifier = {bridge = "br${local.l2_svd}"}
  enable_vlan = true
  ip = {
    enable_arp_accept = true
  }
  mtu = "9169"
}

resource "vyos_interfaces_bridge_vif" "l2_svis" {
  for_each = local.l2_vnis

  depends_on = [
    vyos_interfaces_bridge.vxlan_bridge_L2
  ]

  identifier = {
    bridge = each.value.bridge
    vif    = each.value.bridge_vif
  }

  address = [
    "${each.value.anycast_gw_ip}/${each.value.anycast_gw_cidr}"
  ]

  mac = each.value.anycast_mac
  vrf = each.value.vrf

  ip = {
    enable_arp_accept = true
  }
}

resource "vyos_interfaces_bridge_vif" "l3_vifs" {
  for_each = var.vnis.l3

  depends_on = [
    vyos_interfaces_bridge.vxlan_bridge_L2
  ]

  identifier = {
    bridge = "br${local.l2_svd}"
    vif    = each.value.ext_l3_vlan
  }
  vrf = each.value.vrf

  ip = {
    enable_arp_accept = true
  }
}


resource "vyos_interfaces_bridge_member_interface" "l2vni_vxlan_bridge_member" {
  depends_on = [
    vyos_interfaces_bridge.vxlan_bridge_L2,
  ]
  identifier = {
    bridge = "br${local.l2_svd}"
    interface = "vxlan${local.l2_svd}"
  }
}

