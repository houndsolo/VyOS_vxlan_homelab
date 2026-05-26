module "create_vyos_vms" {
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  source = "./proxmox_vteps"
  host_node = each.value
  leaves= var.leaves
  spines = var.spines
}

module "greatfox_vtep" {
  for_each = { for leaf in var.gf_leafs : leaf.node_id => leaf }
  source = "./greatfox_vtep"
  host_node = each.value
  leaves= var.leaves
  spines = var.spines
  providers = {
    proxmox    = proxmox.greatfox
  }
}

module "create_vyos_border_leaves" {
  for_each = { for leaf in var.border_leaves : leaf.node_id => leaf }
  source = "./proxmox_vteps"
  host_node = each.value
  leaves= var.leaves
  spines = var.spines
}

