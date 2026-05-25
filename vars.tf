locals {
  bgp_l2vpn = {
    her              = true
    flooding_disable = false
    advertise_svi    = false
    advertise_vni    = true
    rt_auto_derive   = false
  }

  vxlan = {
    mtu                       = 9119
    disable_forwarding        = false
    disable_arp_filter        = false
    enable_arp_accept         = false
    enable_arp_announce       = false
    enable_directed_broadcast = false
    enable_proxy_arp          = false
    proxy_arp_pvlan           = false
    external                  = false
    neighbor_suppress         = false
    nolearning                = true
    vni_filter                = false
  }
}

variable "fabric" {
  type = object({
    spines = map(object({
      id = number
    }))

    leaves = map(object({
      id              = number
      hypervisor_node = string
    }))
    border_leaves = map(object({
      id              = number
      hypervisor_node = string
    }))
    leaves_greatfox = map(object({
      id              = number
      hypervisor_node = string
    }))
  })
}

variable "dns" {
  description = "DNS configuration"
  type = object({
    name_servers  = list(string)
    domain_name   = string
    domain_search = list(string)
  })
}


variable "vnis" {
  type = object({
    l3 = map(object({
      vni             = number
      vrf             = string
      vrf_table       = number
      ipv4_rt_imports = optional(string, null)
      ipv4_rt_exports = optional(string, null)
      ipv4_rt_both    = optional(string, null)
      evpn_rt_imports = optional(list(string), [])
      evpn_rt_exports = optional(list(string), [])
      ext_l3_vlan     = optional(number)
      export_vpn_ipv4 = optional(bool, false)
      redistribute_ipv4 = optional(object({
        connected = optional(object({}), null)
        static    = optional(object({}), null)
      }))
      l2 = optional(map(object({
        vni                  = number
        vlan_id              = number
        anycast_gw_ip        = string
        anycast_gw_cidr      = number
        anycast_mac          = string
        advertise_default_gw = optional(bool, false)
        advertise_svi_ip     = optional(bool, false)
        export_ipv4_unicast  = optional(bool, false)
      })), {})
    }))
  })
}
