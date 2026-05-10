resource "vyos_interfaces_ethernet" "link_to_vms" {
  depends_on = [vyos_interfaces_ethernet_vif.link_to_spines_vifs_switch2]
  identifier = { ethernet = "eth3" }
  description = "link to vms"
  mtu = "9119"
  lifecycle {
    ignore_changes = [
      hw_id,
      offload
    ]
  }
}

#resource "vyos_interfaces_ethernet_vif" "eth_3_vifs" {
#  depends_on = [
#    vyos_vrf_name.create_vrfs
#  ]
#  for_each = local.l2_vnis
#  identifier = {
#    ethernet = "eth3"
#    vif = each.value.vlan_id
#  }
#}

resource "vyos_interfaces_bridge_member_interface" "br0_eth3" {
  depends_on = [
    #    vyos_interfaces_ethernet_vif.eth_3_vifs,
    vyos_interfaces_bridge.vxlan_bridge_L2,
  ]

  #  for_each = local.l2_vnis
  identifier = {
    bridge = "br${local.l2_svd}"
    interface = "eth3"
    #interface = "eth3.${each.value.l2_key}"
  }
}
