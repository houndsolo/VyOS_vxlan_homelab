provider "proxmox" {
  endpoint = "https://10.20.7.21:8006"
  api_token = var.pve_api_token
  insecure = true

  ssh {
    username    = "root"
    private_key = file("~/.ssh/id_rsa")
  }
}

provider "proxmox" {
  endpoint = "https://10.20.7.20:8006"
  alias = "greatfox"
  api_token = var.gf_api_token
  insecure = true

  ssh {
    username    = "root"
    private_key = file("~/.ssh/id_rsa")
  }
}
