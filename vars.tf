locals {
  vxlan_mtu = 9119
  disable_forwarding = false
  disable_arp_filter = false
  enable_arp_accept = false
  enable_arp_announce = false
  enable_directed_broadcast = false
  enable_proxy_arp = false
  proxy_arp_pvlan = false

  vxlan_external = false
  vxlan_neighbor_suppress = true
  vxlan_nolearning = true
  vxlan_vni_filter = false

  rt_auto_derive = false
  bgp_l2vpn_flooding_disable = false
  bgp_l2vpn_her = true
  bgp_l2vpn_advertise_svi = false
  bgp_l2vpn_advertise_vni = true
}

variable "fabric" {
  type = object({
    spines = map(object({
      id  = number
    }))

    leaves = map(object({
      id  = number
      hypervisor_node = string
    }))
    border_leaves = map(object({
      id  = number
      hypervisor_node = string
    }))
    leaves_greatfox = map(object({
      id  = number
      hypervisor_node = string
    }))
  })
}

variable "dns" {
  description = "DNS configuration"
  type = object({
    name_servers = list(string)
    domain_name = string
    domain_search = list(string)
  })
}


variable "vnis" {
  type = object({
    l2 = map(object({
      vni         = number
      vrf         = string
      vlan_id     = optional(number)
      anycast_gw_ip  = optional(string)
      anycast_gw_cidr  = optional(string)
      anycast_mac = optional(string)
      description = optional(string)
      advertise_default_gw = bool
      advertise_svi_ip = bool
    }))
    l3 = map(object({
      vni      = number
      vrf         = string
      vrf_table   = number
      rt_imports  = string
      rt_exports  = string
      description = optional(string)
    }))
  })
}

