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
variable "fabric" {
}
