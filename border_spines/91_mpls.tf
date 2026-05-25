locals {
  mpls_interfaces = concat(flatten([
    for leaf in var.fabric.border_leaves : [
      "eth1.${1000 + 100 * var.node.id + leaf.id}",
      "eth2.${2000 + 100 * var.node.id + leaf.id}"
    ]
    ]),
    ["eth3"]
  )
}

resource "vyos_protocols_mpls" "mpls_interfaces" {
  interface = local.mpls_interfaces
}

resource "vyos_protocols_mpls_ldp_interface" "ldp_router_interfaces" {
  for_each   = toset(local.mpls_interfaces)
  identifier = { interface = each.value }
}

resource "vyos_protocols_mpls_ldp" "ldp_router_id" {
  router_id = local.vxlan_loopback_net
}


resource "vyos_protocols_mpls_ldp_discovery" "ldp_discovery" {
  #transport_ipv4_address = local.vxlan_loopback_net
  transport_ipv6_address = local.mpls_v6_loopback_net
}
