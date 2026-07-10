locals {
  vm_leaves = merge(
    { for name, leaf in var.fabric.leaves : name => merge(leaf, { hostname = "vtep-${name}" }) if leaf.is_vm },
    { for name, leaf in var.fabric.border_leaves : name => merge(leaf, { hostname = "vtep-border-${leaf.id}" }) if leaf.is_vm },
    { for name, leaf in var.fabric.fabric_ext_leaves : name => merge(leaf, { hostname = "vtep-fabric-ext-${leaf.id}" }) if leaf.is_vm },
  )

  vm_leaves_greatfox = {
    for name, leaf in var.fabric.leaves_greatfox :
    name => merge(leaf, { hostname = "vtep-${name}" })
    if leaf.is_vm
  }
}

module "create_vyos_vms" {
  for_each        = local.vm_leaves
  source          = "./proxmox_vteps"
  host_node       = each.value
  spines          = length(var.fabric.spines)
  vm_config       = var.proxmox_vtep_vm
  fabric_defaults = var.fabric.defaults
}

module "create_vyos_vms_greatfox" {
  for_each        = local.vm_leaves_greatfox
  source          = "./proxmox_vteps"
  host_node       = each.value
  spines          = length(var.fabric.spines)
  vm_config       = var.proxmox_vtep_vm
  fabric_defaults = var.fabric.defaults

  providers = {
    proxmox = proxmox.greatfox
  }
}
