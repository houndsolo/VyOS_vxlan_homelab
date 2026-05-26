terraform {
  required_providers {
    vyos = {
      source  = "registry.terraform.io/echowings/vyos-rolling"
      version = "0.21.202507150"
    }
    proxmox = {
      source  = "local/houndsolo/proxmox"
      version = "0.100.0"
    }
  }
}
