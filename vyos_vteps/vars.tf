locals {
  underlay_local_as = 700 + var.node.id
  hostname = "LEAF-${var.node.id}"

  vxlan_loopback = "${local.vxlan_loopback_net}/32"
  vxlan_loopback_net = "10.255.240.${var.node.id}"
  bgp_system_as = 700
  vxlan_source_interface = "dum240"

  vxlan_peers = {
    for leaf_name, leaf in var.fabric.leaves:
    leaf_name => merge(leaf, {
      vxlan_loopback = "10.255.240.${leaf.id}"
    })
    if leaf.id != var.node.id
  }
}

variable "dns" {
}
variable "node" {
}
variable "vxlan_mtu" {
}
variable "disable_forwarding" {
}
variable "disable_arp_filter" {
}
variable "enable_arp_accept" {
}
variable "enable_arp_announce" {
}
variable "enable_directed_broadcast" {
}
variable "enable_proxy_arp" {
}
variable "proxy_arp_pvlan" {
}
variable "vxlan_external" {
}
variable "vxlan_neighbor_suppress" {
}
variable "vxlan_nolearning" {
}
variable "vxlan_vni_filter" {
}
variable "bgp_l2vpn_flooding_disable" {
}
variable "bgp_l2vpn_her" {
}
variable "bgp_l2vpn_advertise_svi" {
}
variable "bgp_l2vpn_advertise_vni" {
}
variable "fabric" {
}
variable "rt_auto_derive" {
}
variable "vnis" {
}
