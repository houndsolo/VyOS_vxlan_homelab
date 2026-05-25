
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

#resource "vyos_policy_as_path_list_rule" "as_path_local_rule_2" {
#  depends_on = [resource.vyos_policy_as_path_list.create_as_path_list]
#
#  identifier = {
#    as_path_list = "local_as_export"
#    rule        = 20
#  }
#
#  action = "permit"
#  regex = "^70[12]$"
#}

resource "vyos_policy_route_map" "create_route_map_local_as" {
  depends_on = [resource.vyos_policy_as_path_list_rule.as_path_local_rule]
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

