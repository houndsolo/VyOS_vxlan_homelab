#resource "vyos_protocols_bgp_peer_group" "peer_group_FW_l3_out" {
#  identifier = {
#    peer_group = "FW_L3_out"
#  }
#  capability = {
#    dynamic = true
#    extended_nexthop = true
#  }
#  remote_as = local.ext_l3_asn
#  ebgp_multihop = 20
#  address_family = {
#    ipv4_vpn = {
#      soft_reconfiguration = {inbound = true}
#    }
#  }
#}
#
#resource "vyos_protocols_bgp_neighbor" "fw_wan_conectivity" {
#  depends_on = [vyos_protocols_bgp_peer_group.peer_group_FW_l3_out]
#  identifier = {
#    neighbor = "10.255.240.255"
#  }
#  peer_group = "FW_L3_out"
#}
#
#resource "vyos_interfaces_ethernet" "set_eth3_mtu" {
#  identifier = { ethernet = "eth3" }
#  description = "FW-WAN connectivity"
#  mtu = "9169"
#  address = ["10.250.${var.node.id}.1/31"]
#  lifecycle {
#    ignore_changes = [
#      hw_id,
#      offload
#    ]
#  }
#}


resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch1_ldp" {
  depends_on = [vyos_interfaces_ethernet.set_eth1_mtu]
  for_each =  var.fabric.border_leaves
  address = ["10.251.${var.node.id}${each.value.id}.0/31"]

  identifier = {
    ethernet = "eth1"
    vif = 1000 + 100 * var.node.id + each.value.id
  }
  description = "mpls ldp ipv4 link"
  mtu = "9169"

}

resource "vyos_interfaces_ethernet_vif" "link_to_leaves_vifs_switch2_ldp" {
  depends_on = [vyos_interfaces_ethernet.set_eth2_mtu]
  for_each =  var.fabric.border_leaves
  address = ["10.252.${var.node.id}${each.value.id}.0/31"]

  identifier = {
    ethernet = "eth2"
    vif = 2000 + 100 * var.node.id + each.value.id
  }
  description = "mpls ldp ipv4 link"
  mtu = "9169"

}

