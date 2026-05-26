resource "vyos_system" "host_parameters" {
  domain_name   = var.dns.domain_name
  domain_search = var.dns.domain_search
  name_server   = var.dns.name_servers
  host_name     = local.hostname
}

resource "vyos_system_ip_multipath" "set_multipath" {
  ignore_unreachable_nexthops = true
  layer4_hashing              = true
}
