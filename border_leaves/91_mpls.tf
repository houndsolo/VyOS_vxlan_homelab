locals {
  mpls_interfaces = flatten([
  for spine in var.fabric.spines:[
    "eth1.${3000 + 100*spine.id + var.node.id}",
    "eth2.${3000 + 100*spine.id + var.node.id}",
  ]
  ])
}

resource "vyos_protocols_mpls" "mpls_interfaces" {
  interface = local.mpls_interfaces
}

resource "vyos_protocols_mpls_ldp_interface" "ldp_router_interfaces"{
  for_each = toset(local.mpls_interfaces)
  identifier = { interface = each.value }
}

resource "vyos_protocols_mpls_ldp" "ldp_router_id"{
  router_id = local.mpls_loopback_net
}


resource "vyos_protocols_mpls_ldp_discovery" "ldp_discovery"{
  transport_ipv4_address = local.mpls_loopback_net
  #transport_ipv6_address = local.mpls_v6_loopback_net
}


