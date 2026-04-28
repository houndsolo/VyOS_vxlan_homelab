resource "vyos_protocols_bgp_address_family_l2vpn_evpn_vni" "vni_bgp_config" {
  for_each = var.vnis.l2
  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
  identifier = { vni = each.value.vni }
  rd = "${local.vxlan_loopback_net}:${tostring(each.value.vni)}"
  advertise_default_gw = false
  advertise_svi_ip     = false
}


resource "vyos_interfaces_vxlan" "vxlan_interfaces_L3" {
  depends_on = [vyos_protocols_bgp_address_family_l2vpn_evpn_vni.vni_bgp_config]
  for_each = var.vnis.l3
  identifier = { vxlan = "vxlan${each.value.vni}" }
  source_interface = local.vxlan_source_interface
  mtu = var.vxlan_mtu
  ip = {
    disable_arp_filter = var.disable_arp_filter
    disable_forwarding = var.disable_forwarding
    enable_arp_accept = var.enable_arp_accept
    enable_arp_announce = var.enable_arp_announce
    enable_directed_broadcast = var.enable_directed_broadcast
    enable_proxy_arp = var.enable_proxy_arp
    proxy_arp_pvlan = var.proxy_arp_pvlan
  }
  ipv6 = {
    disable_forwarding = true
  }
  parameters = {
    external = var.vxlan_external
    neighbor_suppress = var.vxlan_neighbor_suppress
    nolearning = var.vxlan_nolearning
    vni_filter = var.vxlan_vni_filter
  }
  vni = each.value.vni
}

resource "vyos_interfaces_bridge" "vxlan_bridge_L3" {
  for_each = var.vnis.l3
  depends_on = [vyos_interfaces_vxlan.vxlan_interfaces_L3]
  identifier = {bridge = "br${each.value.vni}"}
  mtu = "9169"
  vrf = each.value.vrf
}

resource "vyos_interfaces_bridge_member_interface" "br0_vxlan0" {
  depends_on = [
    vyos_interfaces_bridge.vxlan_bridge_L3
  ]
  for_each = var.vnis.l3
  identifier = {
    bridge = "br${each.value.vni}"
    interface = "vxlan${each.value.vni}"
  }
}

resource "vyos_vrf_name" "create_vrfs" {
  for_each = var.vnis.l3

  identifier = { name = each.value.vrf }

  table = each.value.vrf_table
  vni   = each.value.vni

  protocols = {
    bgp = {
      system_as = local.bgp_system_as

      parameters = {
        router_id = local.vxlan_loopback_net

        bestpath = {
          as_path = { multipath_relax = true }
        }
      }

      address_family = {
        ipv4_unicast = merge(
          {
            import = { vpn = true }
            export = { vpn = true }
          },

          (
            try(each.value.rt_imports, null) != null ||
            try(each.value.rt_exports, null) != null
          ) ? {
            route_target = {
              vpn = merge(
                try(each.value.rt_imports, null) != null ? {
                  import = each.value.rt_imports
                } : {},

                try(each.value.rt_exports, null) != null ? {
                  export = each.value.rt_exports
                } : {}
              )
            }
          } : {}
        )

        l2vpn_evpn = {
          rd = "${local.vxlan_loopback_net}:${each.value.vni}"
            route_target = {
            both = ["${local.bgp_system_as}:${each.value.vni}"]
            }
          advertise = {
            ipv4 = { unicast = {} }
          }
        }
      }
    }
  }
}
