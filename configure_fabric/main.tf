module "spines" {

  for_each  = var.fabric.spines
  source    = "./spines"
  providers = { vyos = vyos.spines[each.key] }
  node      = each.value
  dns       = var.dns
  fabric    = var.fabric

  bgp_l2vpn = local.bgp_l2vpn
  vnis      = var.vnis

  vxlan = local.vxlan
}

module "leaf_vms" {
  for_each  = var.fabric.leaves
  source    = "./leaves"
  providers = { vyos = vyos.leaves[each.key] }
  node      = each.value
  dns       = var.dns
  fabric    = var.fabric

  bgp_l2vpn = local.bgp_l2vpn
  vnis      = var.vnis

  vxlan = local.vxlan
}

module "greatfox_leaf_vms" {
  for_each  = var.fabric.leaves_greatfox
  source    = "./leaves"
  providers = { vyos = vyos.greatfox }
  node      = each.value
  dns       = var.dns
  fabric    = var.fabric

  bgp_l2vpn = local.bgp_l2vpn
  vnis      = var.vnis

  vxlan = local.vxlan
}

module "border_leaf_vms" {
  for_each  = var.fabric.border_leaves
  source    = "./border_leaves"
  providers = { vyos = vyos.border_leaves[each.key] }
  node      = each.value
  dns       = var.dns
  fabric    = var.fabric

  bgp_l2vpn = local.bgp_l2vpn
  vnis      = var.vnis

  vxlan = local.vxlan
}

module "fabric_ext_leaf_vms" {
  for_each  = var.fabric.fabric_ext_leaves
  source    = "./leaves"
  providers = { vyos = vyos.fabric_leaves[each.key] }
  node      = each.value
  dns       = var.dns
  fabric    = var.fabric

  bgp_l2vpn = local.bgp_l2vpn
  vnis      = var.vnis

  vxlan = local.vxlan
}

