locals {
  ipv4_vpn_export_policy = {
    l3 = {
      for l3_key, l3 in var.vnis.l3 :
      l3_key => l3
      if length([
        for l2_key, l2 in l3.l2 :
        l2_key
        if try(l2.export_ipv4_unicast, false)
      ]) > 0
    }

    l2 = merge([
      for l3_key, l3 in var.vnis.l3 : {
        for l2_key, l2 in l3.l2 :
        "${l3_key}-${l2_key}" => {
          l3_key           = l3_key
          l2_key           = l2_key
          vrf              = l3.vrf
          vlan_id          = l2.vlan_id
          prefix           = cidrsubnet("${l2.anycast_gw_ip}/${l2.anycast_gw_cidr}", 0, 0)
          prefix_list_name = "PL-${upper(replace(l3.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
          route_map_name   = "RM-${upper(replace(l3.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
          rule             = tonumber(l2.vlan_id) * 10
        }
        if try(l2.export_ipv4_unicast, false)
      }
    ]...)
  }
}

resource "vyos_policy_prefix_list" "create_prefix_list" {
  for_each = local.ipv4_vpn_export_policy.l3
  identifier = {
    prefix_list = "PL-${upper(replace(each.value.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
  }
}

resource "vyos_policy_prefix_list_rule" "ipv4_vpn_export_prefix_rules" {
  depends_on = [resource.vyos_policy_prefix_list.create_prefix_list]
  for_each = local.ipv4_vpn_export_policy.l2

  identifier = {
    prefix_list = each.value.prefix_list_name
    rule        = each.value.rule
  }

  action = "permit"
  prefix = each.value.prefix
}

resource "vyos_policy_route_map" "create_route_map" {
  for_each = local.ipv4_vpn_export_policy.l3

  identifier = {
    route_map = "RM-${upper(replace(each.value.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
  }
}

resource "vyos_policy_route_map_rule" "ipv4_vpn_export_permit" {
  depends_on = [resource.vyos_policy_route_map.create_route_map]
  for_each = local.ipv4_vpn_export_policy.l3

  identifier = {
    route_map = "RM-${upper(replace(each.value.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
    rule      = 10
  }

  action = "permit"
  match = {
    ip = {
      address = {
        prefix_list = "PL-${upper(replace(each.value.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
      }
    }
  }
}

resource "vyos_policy_route_map_rule" "ipv4_vpn_export_deny" {
  for_each = local.ipv4_vpn_export_policy.l3

  identifier = {
    route_map = "RM-${upper(replace(each.value.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
    rule      = 100
  }

  action = "deny"
}

resource "vyos_vrf_name" "create_vrfs" {
  depends_on = [vyos_protocols_bgp.enable_bgp]
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
            export = { vpn = true }
            import = { vpn = true }
            rd =  {
              vpn = {
                export = "${local.vxlan_loopback_net}:${each.value.vni}"
              }
            }
            route_target = {
              vpn =   {
                import = each.value.ipv4_rt_imports
                export = each.value.ipv4_rt_exports
              }
            }
            soft_reconfiguration = { inbound = true }
          },
          each.value.redistribute_ipv4 != null ? {
            redistribute = each.value.redistribute_ipv4
          } : {},
          contains(keys(local.ipv4_vpn_export_policy.l3), each.key) ? {
            route_map = {
              vpn = {
                export = "RM-${upper(replace(each.value.vrf, "_", "-"))}-IPV4-VPN-EXPORT"
              }
            }
          } : {}
        )
        l2vpn_evpn = {
          rd = "${local.vxlan_loopback_net}:${each.value.vni}"
          route_target = {
            import = each.value.evpn_rt_imports
            export = each.value.evpn_rt_exports
          }
        }
      }
    }
  }
}
