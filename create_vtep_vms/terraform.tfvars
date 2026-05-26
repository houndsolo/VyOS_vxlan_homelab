fabric = {
  spines = {
    rtr1 = { id = 1 }
    rtr2 = { id = 2 }
  }

  leaves = {
    fichina = { hypervisor_node = "fichina", id = 10, is_vm = true }
    fortuna = { hypervisor_node = "fortuna", id = 11, is_vm = true }
    macbeth = { hypervisor_node = "macbeth", id = 12, is_vm = true }
    titania = { hypervisor_node = "titania", id = 13, is_vm = true }
    zoness  = { hypervisor_node = "zoness", id = 14, is_vm = true }
    venom   = { hypervisor_node = "venom", id = 17, is_vm = true }
    eldarad = { hypervisor_node = "eldarad", id = 21, is_vm = true }
  }

  border_leaves = {
    border18 = { hypervisor_node = "fichina", id = 18, is_vm = true }
    border19 = { hypervisor_node = "eldarad", id = 19, is_vm = true }
  }

  leaves_greatfox = {
    greatfox = {
      hypervisor_node  = "greatfox"
      id               = 20
      is_vm            = true
      underlay_bridges = ["vmbr4001", "vmbr0"]
    }
  }
}
