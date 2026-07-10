locals {
  vxlan_mgmt_cidr   = 16
  vxlan_mgmt_ip     = "10.20.10.${var.host_node.id}"
  vxlan_mgmt_ip_sub = "${local.vxlan_mgmt_ip}/${local.vxlan_mgmt_cidr}"

  vtep_vm_id = "9700${var.host_node.id}"
  vtep_id    = var.host_node.id - 10

  vm_id = local.vtep_id + 700 + 10

  underlay_bridges = coalesce(var.host_node.underlay_bridges, var.vm_config.default_underlay_bridges)

}

variable "spines" {
  type = number
}
variable "host_node" {
  description = "this node"
  type = object({
    hostname         = string
    hypervisor_node  = string
    id               = number
    is_vm            = optional(bool, true)
    underlay_bridges = optional(list(string), null)
  })
}

variable "vm_config" {
  description = "Proxmox VM settings for this VyOS VTEP instance."
  type = object({
    datastore_id             = string
    import_image             = string
    cloud_init_datastore_id  = string
    user_data_file_id        = string
    management_bridge        = string
    default_underlay_bridges = list(string)
    cpu_cores                = number
    cpu_type                 = string
    memory_mb                = number
    disk_size_gb             = number
  })
}
