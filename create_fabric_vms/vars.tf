variable "fabric" {
  type = object({
    spines = map(object({
      id = number
    }))

    leaves = map(object({
      id               = number
      hypervisor_node  = string
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
    fabric_ext_leaves = map(object({
      id               = number
      hypervisor_node  = string
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
    border_leaves = map(object({
      id               = number
      hypervisor_node  = string
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
    leaves_greatfox = map(object({
      id               = number
      hypervisor_node  = string
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
  })
}

variable "pve_api_token" {
  type      = string
  sensitive = true
}

variable "gf_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_vtep_vm" {
  description = "Proxmox VM settings for VyOS VTEP instances."
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
