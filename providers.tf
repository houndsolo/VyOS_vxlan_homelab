provider "vyos" {
  alias = "leaves"
  for_each = var.fabric.leaves
  endpoint ="https://10.20.10.${tostring(each.value.id)}"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "spines"
  for_each = var.fabric.spines
  endpoint ="https://10.20.10.${tostring(each.value.id)}"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  #overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "greatfox"
  endpoint ="https://10.20.10.20"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

provider "vyos" {
  alias = "border"
  for_each = var.fabric.border_leaves
  endpoint ="https://10.20.10.${tostring(each.value.id)}"
  api_key  = var.vyos_key
  certificate = {
    disable_verify = true
  }
  default_timeouts = 2
  overwrite_existing_resources_on_create = true
}

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
