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
