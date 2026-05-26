locals {
  mpls_loopback        = "10.255.230.${var.node.id}/32"
  mpls_loopback_net    = "10.255.230.${var.node.id}"
  mpls_v6_loopback     = "fd69:420::${var.node.id}/128"
  mpls_v6_loopback_net = "fd69:420::${var.node.id}"
  ospf_interfaces = concat(flatten([
    for leaf in var.fabric.border_leaves : [
      "eth2.${2000 + 100 * var.node.id + leaf.id}"
    ]
    ]),
    ["eth3"]
  )
  mpls_interfaces = concat(flatten([
    for leaf in var.fabric.border_leaves : [
      "eth1.${1000 + 100 * var.node.id + leaf.id}",
      "eth2.${2000 + 100 * var.node.id + leaf.id}"
    ]
    ]),
    ["eth3"]
  )

  ospf_area0_networks = concat(
    [
      local.mpls_loopback,
    ],
    flatten([
      for leaf_name, leaf in var.fabric.leaves : [
        "10.251.${var.node.id}${leaf.id}.0/31",
        "10.252.${var.node.id}${leaf.id}.0/31",
      ]
    ])
  )

}

resource "vyos_interfaces_dummy" "dummy_interface_mpls" {
  identifier = { dummy = "dum469" }
  address = [
    local.mpls_loopback,
  ]
  mtu = "9169"
}

resource "vyos_protocols_mpls" "mpls_interfaces" {
  interface = local.mpls_interfaces
}

resource "vyos_protocols_mpls_ldp_interface" "ldp_router_interfaces" {
  for_each   = toset(local.mpls_interfaces)
  identifier = { interface = each.value }
}

resource "vyos_protocols_mpls_ldp" "ldp_router_id" {
  router_id = local.mpls_loopback_net
}


resource "vyos_protocols_mpls_ldp_discovery" "ldp_discovery" {
  transport_ipv4_address = local.mpls_loopback_net
}

resource "vyos_protocols_ospf" "enable_ospf" {
  passive_interface = "default"
}

resource "vyos_protocols_ospf_interface" "enable_ospf" {
  for_each   = toset(local.ospf_interfaces)
  identifier = { interface = each.value }
  passive    = { disable = true }
  network    = "point-to-point"
  area       = "0"
}

resource "vyos_protocols_ospf_interface" "enable_ospf_non_broadcast" {
  for_each   = var.fabric.border_leaves
  identifier = { interface = "eth1.${1000 + 100 * var.node.id + each.value.id}" }
  passive    = { disable = true }
  network    = "non-broadcast"
  area       = "0"
}

resource "vyos_protocols_ospf_neighbor" "non_broadcast_neighbor" {
  for_each   = var.fabric.border_leaves
  identifier = { neighbor = "10.251.${100 * var.node.id + each.value.id}.1" }
}

resource "vyos_protocols_ospf_interface" "enable_ospf_dum469" {
  identifier = { interface = "dum469" }
  passive    = { disable = false }
  area       = "0"
}

resource "vyos_protocols_ospf_interface" "enable_ospf_dum240" {
  identifier = { interface = "dum240" }
  passive    = { disable = false }
  area       = "0"
}

resource "vyos_protocols_ospf_redistribute_bgp" "redistribute_fabric_vteps_to_BL" {}

