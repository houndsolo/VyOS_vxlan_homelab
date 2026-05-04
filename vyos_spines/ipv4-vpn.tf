#resource "vyos_vrf_name" "create_vrfs" {
#  for_each = var.vnis.l3
#
#  identifier = { name = each.value.vrf }
#
#  table = each.value.vrf_table
#  vni   = each.value.vni
#
#  protocols = {
#    bgp = {
#      system_as = local.bgp_system_as
#
#      parameters = {
#        router_id = local.vxlan_loopback_net
#
#        bestpath = {
#          as_path = { multipath_relax = true }
#        }
#      }
#
#      address_family = {
#        ipv4_unicast = merge(
#          {
#            import = { vpn = true }
#            export = { vpn = true }
#          },
#
#          (
#            try(each.value.rt_imports, null) != null ||
#            try(each.value.rt_exports, null) != null
#          ) ? {
#            route_target = {
#              vpn = merge(
#                try(each.value.rt_imports, null) != null ? {
#                  import = each.value.rt_imports
#                } : {},
#
#                try(each.value.rt_exports, null) != null ? {
#                  export = each.value.rt_exports
#                } : {}
#              )
#            }
#          } : {}
#        )
#      }
#    }
#  }
#}
