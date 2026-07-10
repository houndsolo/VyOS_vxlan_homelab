variable "fabric" {
  type = object({
    defaults = object({
      bgp_system_as                     = number
      underlay_local_as_base            = number
      ipv4_loopback_prefix              = string
      ipv6_underlay_prefix              = string
      vxlan_source_interface            = string
      l2_service_bridge_id              = number
      vyos_mgmt_prefix                  = string
      vyos_mgmt_cidr                    = number
      vyos_provider_default_timeouts    = number
      vyos_provider_disable_verify      = bool
      vyos_overwrite_existing_on_create = bool
    })
    bgp_l2vpn = object({
      flooding_disable = bool
      her              = bool
      advertise_svi    = bool
      advertise_vni    = bool
      rt_auto_derive   = bool
    })
    vxlan = object({
      mtu                       = number
      outer_mtu                 = number
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
    evpn_rr = optional(map(object({
      id               = number
      hypervisor_node  = optional(string, null)
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    })), {})
    spines = map(object({
      id              = number
      uplink_if       = optional(string, null)
      hypervisor_node = optional(string, null)
    }))

    leaves = map(object({
      id               = number
      hypervisor_node  = optional(string, null)
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
    fabric_ext_leaves = map(object({
      id               = number
      hypervisor_node  = optional(string, null)
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
    border_leaves = map(object({
      id               = number
      hypervisor_node  = optional(string, null)
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
    leaves_greatfox = map(object({
      id               = number
      hypervisor_node  = optional(string, null)
      is_vm            = optional(bool, true)
      underlay_bridges = optional(list(string), null)
    }))
  })
}

locals {
  derived_node_defaults = {
    for node_id in distinct(concat(
      [for node in values(var.fabric.spines) : node.id],
      [for node in values(var.fabric.leaves) : node.id],
      [for node in values(var.fabric.leaves_greatfox) : node.id],
      [for node in values(var.fabric.border_leaves) : node.id],
    )) :
    node_id => {
      l2_svd                 = var.fabric.defaults.l2_service_bridge_id
      underlay_local_as      = var.fabric.defaults.underlay_local_as_base + node_id
      vxlan_loopback_net     = cidrhost(var.fabric.defaults.ipv4_loopback_prefix, node_id)
      vxlan_loopback         = "${cidrhost(var.fabric.defaults.ipv4_loopback_prefix, node_id)}/32"
      vxlan_loopback_v6_net  = cidrhost(var.fabric.defaults.ipv6_underlay_prefix, node_id)
      vxlan_loopback_v6      = "${cidrhost(var.fabric.defaults.ipv6_underlay_prefix, node_id)}/128"
      bgp_system_as          = var.fabric.defaults.bgp_system_as
      vxlan_source_interface = var.fabric.defaults.vxlan_source_interface
    }
  }

  derived_fabric = {
    spines = {
      for node_name, node in var.fabric.spines :
      node_name => merge(node, local.derived_node_defaults[node.id])
    }

    leaves = {
      for node_name, node in var.fabric.leaves :
      node_name => merge(node, local.derived_node_defaults[node.id], {
        hostname = "LEAF-${node.id}"
      })
    }

    leaves_greatfox = {
      for node_name, node in var.fabric.leaves_greatfox :
      node_name => merge(node, local.derived_node_defaults[node.id], {
        hostname = "LEAF-${node.id}"
      })
    }

    border_leaves = {
      for node_name, node in var.fabric.border_leaves :
      node_name => merge(node, local.derived_node_defaults[node.id], {
        hostname           = "BORDER-LEAF-${node.id}"
        border_leaf_id_1_2 = node.id - 17
      })
    }
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

        bridge     = "br${var.fabric.defaults.l2_service_bridge_id}"
        bridge_vif = l2.vlan_id
      })
    }
  ]...)

  ipv4_vpn_export_policy = {
    for l3_key, l3 in var.vnis.l3 :
    l3_key => {
      prefix_list_name = "PL-${upper(replace(l3.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
      route_map_name   = "RM-${upper(replace(l3.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
    }
    if length([
      for l2_key, l2 in l3.l2 :
      l2_key
      if try(l2.export_ipv4_unicast, false)
    ]) > 0
  }
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
      vni                = number
      vrf                = string
      vrf_table          = number
      ipv4_rt_imports    = optional(string, null)
      ipv4_rt_exports    = optional(string, null)
      BL_ipv4_rt_imports = optional(string, null)
      BL_ipv4_rt_exports = optional(string, null)
      evpn_rt_imports    = optional(list(string), [])
      evpn_rt_exports    = optional(list(string), [])
      ext_l3_vlan        = optional(number)
      export_vpn_ipv4    = optional(bool, false)
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

variable "vyos_key" {
  type      = string
  sensitive = true
}

variable "external_l3" {
  description = "Border-leaf external L3 connectivity settings."
  type = object({
    interface       = string
    peer_group_name = string
    remote_asn      = number
  })
}
