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
        l2vpn_evpn = {
          rd = "${local.vxlan_loopback_net}:${each.value.vni}"
          route_target = {
            #both = ["${local.bgp_system_as}:${each.value.vni}"]
            import = each.value.rt_imports
            export = each.value.rt_exports
          }
        }
      }
    }
  }
}

