module "configure_vyos_spines" {

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

module "configure_vyos_vms" {
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

module "configure_vyos_vms_greatfox" {
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

module "configure_vyos_border_vms" {
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

