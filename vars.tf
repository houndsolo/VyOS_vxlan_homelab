locals {
  vxlan_mtu = 9119
  disable_forwarding = false
  disable_arp_filter = true
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
  bgp_l2vpn_vni_advertise_svi = false
}

variable "dns" {
  description = "DNS configuration"
  type = object({
    name_servers = list(string)
    domain_name = string
    domain_search = list(string)
  })
  default = {
    name_servers = ["10.8.6.9"]
    domain_name = "lylat.space"
    domain_search = ["lylat.space"]
  }
}

variable "anycast_rp_address" {
  type = string
  default = "10.240.253.255"
}

variable "rp_group_ip_only" {
  type = string
  default = "225.0.0.69"
}
variable "rp_groups" {
  type = list(string)
  default = ["225.0.0.69/32"]
}


variable "spines" {
  type = map(object({
    hostname  = string
    node_id   = number
  }))
}

variable "leaves" {
  description = "List of network nodes with their details."
  type = map(object({
    hostname  = string
    host_node = string
    node_id   = number
  }))
}

