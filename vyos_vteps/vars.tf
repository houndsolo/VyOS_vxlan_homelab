locals {
  dum0_network = "10.240.254.${var.host_node.node_id}/32"
  bgp_system_as = 700

  link_to_spines = [
    for spine_id in range(var.spines) : {
      eth_id  = spine_id + 1
      host_ip = "10.240.${var.host_node.node_id}${spine_id+1}.1/31"
      peer_ip = "10.240.${var.host_node.node_id}${spine_id+1}.0"
      peer_network = "10.240.${var.host_node.node_id}${spine_id+1}.0"
      spine_rp_address = var.anycast_rp_address
    }
  ]
}

variable "dns" {
}
variable "rp_group_ip_only" {
}
variable "host_node" {
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
variable "anycast_rp_address" {
}
variable "rp_groups" {
}
variable "spines" {
}
variable "leaves" {
}

