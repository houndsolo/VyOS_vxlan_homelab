locals {
  vxlan_mgmt_cidr = 16
  vxlan_mgmt_ip = "10.20.10.${var.host_node.node_id}"
  vxlan_mgmt_ip_sub = "${local.vxlan_mgmt_ip}/${local.vxlan_mgmt_cidr}"

  vtep_vm_id = "9700${var.host_node.node_id}"
  vtep_id = var.host_node.node_id - 10

  vm_id = local.vtep_id+700+10

}

variable "vtep_count" {
  type = number
  default = 6
}

variable "spines" {
  type = number
}
variable "host_node" {
  description = "this node"
  type = object({
    hostname  = string
    host_node = string
    node_id   = number
  })
}
variable "leaves" {
  type = list(object({
    hostname  = string
    host_node = string
    node_id   = number
  }))
}
