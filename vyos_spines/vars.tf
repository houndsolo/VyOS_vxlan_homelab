locals {
  vxlan_loopback = "10.255.240.${var.node.id}/32"
  bgp_system_as = 700
  vxlan_source_interface = "dum240"
  underlay_local_as = 700 + var.node.id
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
variable "bgp_l2vpn_vni_advertise_svi" {
}
variable "spines" {
}
variable "leaves" {
}

