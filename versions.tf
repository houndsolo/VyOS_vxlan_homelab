terraform {
  required_providers {
    vyos = {
      source  = "registry.terraform.io/echowings/vyos-rolling"
      version = "0.21.202507150"
    }
    proxmox = {
      source  = "local/mechanic/proxmox"
      version = "0.108.0"
    }
  }
}
