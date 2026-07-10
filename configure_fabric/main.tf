#module "spines" {
#
#  for_each  = var.fabric.spines
#  source    = "./spines"
#  providers = { vyos = vyos.spines[each.key] }
#  node      = local.derived_fabric.leaves[each.key]
#  dns       = var.dns
#  fabric    = var.fabric
#
#  bgp_l2vpn = var.fabric.bgp_l2vpn
#  vnis      = var.vnis
#
#  vxlan = var.fabric.vxlan
#}

module "pve_leaf_vms" {
  for_each  = var.fabric.leaves
  source    = "./pve_leaves"
  providers = { vyos = vyos.leaves[each.key] }
  node      = local.derived_fabric.leaves[each.key]
  dns       = var.dns

  bgp_l2vpn = var.fabric.bgp_l2vpn
  vnis      = var.vnis

  vxlan                  = var.fabric.vxlan
  spines                 = local.derived_fabric.spines
  l2_vnis                = local.l2_vnis
  ipv4_vpn_export_policy = local.ipv4_vpn_export_policy
}

module "greatfox_leaf_vms" {
  for_each  = var.fabric.leaves_greatfox
  source    = "./pve_leaves"
  providers = { vyos = vyos.greatfox }
  node      = local.derived_fabric.leaves_greatfox[each.key]
  dns       = var.dns

  bgp_l2vpn = var.fabric.bgp_l2vpn
  vnis      = var.vnis

  vxlan                  = var.fabric.vxlan
  spines                 = local.derived_fabric.spines
  l2_vnis                = local.l2_vnis
  ipv4_vpn_export_policy = local.ipv4_vpn_export_policy
}

module "border_leaves" {
  for_each  = var.fabric.border_leaves
  source    = "./border_leaves"
  providers = { vyos = vyos.border_leaves[each.key] }
  node      = local.derived_fabric.border_leaves[each.key]
  dns       = var.dns

  bgp_l2vpn   = var.fabric.bgp_l2vpn
  vnis        = var.vnis
  external_l3 = var.external_l3

  vxlan                  = var.fabric.vxlan
  spines                 = local.derived_fabric.spines
  l2_vnis                = local.l2_vnis
  ipv4_vpn_export_policy = local.ipv4_vpn_export_policy
}

#module "fabric_ext_leaf_vms" {
#  for_each  = var.fabric.fabric_ext_leaves
#  source    = "./pve_leaves"
#  providers = { vyos = vyos.fabric_leaves[each.key] }
#  node      = each.value
#  dns       = var.dns
#  fabric    = var.fabric
#
#  bgp_l2vpn = var.fabric.bgp_l2vpn
#  vnis      = var.vnis
#
#  vxlan = var.fabric.vxlan
#}
#
