resource "vyos_policy_prefix_list" "create_prefix_list_vxlan_export" {
  identifier = {
    prefix_list = "vxlan_prefix_export"
  }
}


resource "vyos_policy_prefix_list_rule" "ipv4_export_prefix_rules_ipv4" {
  depends_on = [resource.vyos_policy_prefix_list.create_prefix_list_vxlan_export]

  identifier = {
    prefix_list = "vxlan_prefix_export"
    rule        = 10
  }

  action = "permit"
  prefix = "10.255.240.0/24"
  ge = 32
}

resource "vyos_policy_route_map" "create_route_map_local_as" {
  depends_on = [resource.vyos_policy_prefix_list_rule.ipv4_export_prefix_rules_ipv4]
  identifier = {
    route_map = "local_as_rm"
  }
}

resource "vyos_policy_route_map_rule" "local_as_rm_rule" {
  depends_on = [vyos_policy_route_map.create_route_map_local_as]

  identifier = {
    route_map = "local_as_rm"
    rule      = 10
  }

  action = "permit"

  match = {
    ip = { address = { prefix_list  = "vxlan_prefix_export" } }
  }
}


resource "vyos_policy_prefix_list6" "ipv6_local_pl" {
  identifier = {
    prefix_list6 = "local_ipv6_pl"
  }
}

resource "vyos_policy_prefix_list6_rule" "ipv6_local_pl_rule" {
  depends_on = [resource.vyos_policy_prefix_list6.ipv6_local_pl]


  identifier = {
    prefix_list6 = "local_ipv6_pl"
    rule        = 10
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
    ipv6 = { address = { prefix_list  = "local_ipv6_pl"} }
  }
}
