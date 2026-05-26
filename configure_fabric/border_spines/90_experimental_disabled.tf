resource "vyos_policy_prefix_list6" "ipv6_local_pl" {
  identifier = {
    prefix_list6 = "local_ipv6_pl"
  }
}

resource "vyos_policy_prefix_list6_rule" "ipv6_local_pl_rule" {
  depends_on = [resource.vyos_policy_prefix_list6.ipv6_local_pl]


  identifier = {
    prefix_list6 = "local_ipv6_pl"
    rule         = 10
  }
  action = "permit"
  prefix = local.mpls_v6_loopback
}

resource "vyos_policy_route_map" "create_route_map_local_ipv6" {
  depends_on = [resource.vyos_policy_prefix_list6_rule.ipv6_local_pl_rule]
  identifier = {
    route_map = "local_ipv6_rm"
  }
}

resource "vyos_policy_route_map_rule" "rm_local_ipv6_rule" {
  depends_on = [vyos_policy_route_map.create_route_map_local_ipv6]

  identifier = {
    route_map = "local_ipv6_rm"
    rule      = 10
  }

  action = "permit"

  match = {
    ipv6 = { address = { prefix_list = "local_ipv6_pl" } }
  }
}
