provider "vyos" {
  alias = "leaves"
  for_each = { for leaf in var.leaves : leaf.node_id => leaf }
  endpoint ="https://10.20.240.${tostring(each.value.node_id)}"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "spines"
  for_each = { for spine in var.spines : leaf.node_id => leaf }
  endpoint ="https://10.20.10.${tostring(each.value.node_id)}"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  #overwrite_existing_resources_on_create = true
}

#provider "vyos" {
#  alias = "greatfox"
#  endpoint ="https://10.20.1.20"
#  api_key  = var.vyos_key
#  certificate = {
#    disable_verify = true
#  }
#  default_timeouts = 2
#  overwrite_existing_resources_on_create = true
#}
#
#provider "vyos" {
#  alias = "border"
#  endpoint ="https://10.20.1.80"
#  api_key  = var.vyos_key
#  certificate = {
#    disable_verify = true
#  }
#  default_timeouts = 2
#  overwrite_existing_resources_on_create = true
#}
#
#provider "vyos" {
#  alias = "remote"
#  endpoint ="https://10.20.1.80"
#  api_key  = var.vyos_key
#  certificate = {
#    disable_verify = true
#  }
#  default_timeouts = 2
#  overwrite_existing_resources_on_create = true
#}
#
