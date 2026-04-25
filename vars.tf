locals {
  vxlan_mtu = 9119
  disable_forwarding = false
  disable_arp_filter = false
  enable_arp_accept = false
  enable_arp_announce = false
  enable_directed_broadcast = true
  enable_proxy_arp = false
  proxy_arp_pvlan = false

  vxlan_external = true
  vxlan_neighbor_suppress = false
  vxlan_nolearning = true
  vxlan_vni_filter = false

  bgp_l2vpn_flooding_disable = false
  bgp_l2vpn_her = true
  bgp_l2vpn_advertise_svi = false
  bgp_l2vpn_advertise_vni = true
  bgp_l2vpn_vni_advertise_svi = true
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

