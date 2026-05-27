module "configure_fabric" {
  source = "./configure_fabric"

  fabric   = var.fabric
  dns      = var.dns
  vnis     = var.vnis
  vyos_key = var.vyos_key
}

module "create_fabric_vms" {
  source = "./create_fabric_vms"

  fabric        = var.fabric
  pve_api_token = var.pve_api_token
  gf_api_token  = var.gf_api_token
}
