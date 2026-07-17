# This creates a route map/ AS Path filter to only export originated routes into the BGP Underlay
# aka path length of 0
resource "vyos_policy_as_path_list" "create_as_path_list" {
  identifier = {
    as_path_list = "local_as_export"
  }
}

resource "vyos_policy_as_path_list_rule" "as_path_local_rule" {
  depends_on = [resource.vyos_policy_as_path_list.create_as_path_list]

  identifier = {
    as_path_list = "local_as_export"
    rule         = 10
  }

  action = "permit"
  regex  = "^$"
}

resource "vyos_policy_as_path_list_rule" "as_path_local_rule_extl3" {
  depends_on = [resource.vyos_policy_as_path_list.create_as_path_list]

  identifier = {
    as_path_list = "local_as_export"
    rule         = 20
  }

  action = "permit"
  regex  = "^420$"
}

resource "vyos_policy_route_map" "create_route_map_local_as" {
  depends_on = [
    resource.vyos_policy_as_path_list_rule.as_path_local_rule,
    resource.vyos_policy_as_path_list_rule.as_path_local_rule_extl3
  ]
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
    as_path = "local_as_export"
  }
}




resource "vyos_policy_as_path_list" "block_local_AS_evpn" {
  identifier = {
    as_path_list = "block_local_AS_evpn_PL"
  }
}

resource "vyos_policy_as_path_list_rule" "block_local_AS_evpn_rule" {
  depends_on = [resource.vyos_policy_as_path_list.block_local_AS_evpn]

  identifier = {
    as_path_list = "block_local_AS_evpn_PL"
    rule         = 10
  }

  action = "permit"
  regex  = "^$"
}

resource "vyos_policy_route_map" "route_map_block_local_evpn" {
  depends_on = [
    resource.vyos_policy_as_path_list_rule.as_path_local_rule,
    resource.vyos_policy_as_path_list_rule.as_path_local_rule_extl3
  ]
  identifier = {
    route_map = "block_local_as_rm"
  }
}

resource "vyos_policy_route_map_rule" "route_map_block_local_evpn_rule" {
  depends_on = [vyos_policy_route_map.route_map_block_local_evpn]

  identifier = {
    route_map = "block_local_as_rm"
    rule      = 10
  }

  action = "deny"

  match = {
    as_path = "block_local_AS_evpn_PL"
  }
}

resource "vyos_policy_route_map_rule" "route_map_block_local_evpn_rule_2" {
  depends_on = [vyos_policy_route_map.route_map_block_local_evpn]

  identifier = {
    route_map = "block_local_as_rm"
    rule      = 100
  }

  action = "permit"
}
