locals {
  l2_svd            = 9000
  underlay_local_as = 700 + var.node.id
  hostname          = "LEAF-${var.node.id}"

  vxlan_loopback         = "${local.vxlan_loopback_net}/32"
  vxlan_loopback_net     = "10.255.240.${var.node.id}"
  bgp_system_as          = 700
  vxlan_source_interface = "dum240"

  vxlan_peers = {
    for leaf_name, leaf in var.fabric.leaves :
    leaf_name => merge(leaf, {
      vxlan_loopback = "10.255.240.${leaf.id}"
    })
    if leaf.id != var.node.id
  }

  l2_vnis = merge([
    for l3_key, l3 in var.vnis.l3 : {
      for l2_key, l2 in try(l3.l2, {}) :
      tostring(l2.vni) => merge(l2, {
        l3_key = l3_key
        l2_key = l2_key

        l3_vni = l3.vni

        vrf       = l3.vrf
        vrf_table = l3.vrf_table

        bridge     = "br${local.l2_svd}"
        bridge_vif = l2.vlan_id
      })
    }
  ]...)
}

variable "dns" {
}
variable "node" {
}
variable "vxlan" {
  type = object({
    mtu                       = number
    disable_forwarding        = bool
    disable_arp_filter        = bool
    enable_arp_accept         = bool
    enable_arp_announce       = bool
    enable_directed_broadcast = bool
    enable_proxy_arp          = bool
    proxy_arp_pvlan           = bool
    external                  = bool
    neighbor_suppress         = bool
    nolearning                = bool
    vni_filter                = bool
  })
}

variable "bgp_l2vpn" {
  type = object({
    flooding_disable = bool
    her              = bool
    advertise_svi    = bool
    advertise_vni    = bool
    rt_auto_derive   = bool
  })
}
variable "fabric" {
}
variable "vnis" {
}
