locals {
  mpls_loopback        = "10.255.230.${var.node.id}/32"
  mpls_loopback_net    = "10.255.230.${var.node.id}"
  mpls_v6_loopback     = "fd69:420::${var.node.id}/128"
  mpls_v6_loopback_net = "fd69:420::${var.node.id}"

  ospf_interfaces = flatten([
    for spine in var.fabric.spines : [
      "eth2.${2000 + 100 * spine.id + var.node.id}",
    ]
  ])
  mpls_interfaces = flatten([
    for spine in var.fabric.spines : [
      "eth1.${1000 + 100 * spine.id + var.node.id}",
      "eth2.${2000 + 100 * spine.id + var.node.id}",
    ]
  ])

  ospf_area0_networks = concat(
    [
      local.mpls_loopback,
    ],
    flatten([
      for spine_name, spine in var.fabric.spines : [
        "10.251.${spine.id}${var.node.id}.1/31",
        "10.252.${spine.id}${var.node.id}.1/31",
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
  depends_on = [
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch1,
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch2
  ]
  interface = local.mpls_interfaces
}

resource "vyos_protocols_mpls_ldp_interface" "ldp_router_interfaces" {
  depends_on = [
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch1,
    vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch2
  ]
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
  depends_on = [vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch2]
  for_each   = toset(local.ospf_interfaces)
  identifier = { interface = each.value }
  passive    = { disable = true }
  network    = "point-to-point"
  area       = "0"
}

resource "vyos_protocols_ospf_interface" "enable_ospf_non_broadcast" {
  depends_on = [vyos_interfaces_ethernet_vif.link_to_leaves_vifs_switch1]
  for_each   = var.fabric.spines
  identifier = { interface = "eth1.${1000 + 100 * each.value.id + var.node.id}" }
  passive    = { disable = true }
  network    = "non-broadcast"
  area       = "0"
}

resource "vyos_protocols_ospf_neighbor" "non_broadcast_neighbor" {
  for_each   = var.fabric.spines
  identifier = { neighbor = "10.251.${100 * each.value.id + var.node.id}.0" }
}


resource "vyos_protocols_ospf_interface" "enable_ospf_dum469" {
  depends_on = [vyos_interfaces_dummy.dummy_interface_mpls]
  identifier = { interface = "dum469" }
  passive    = { disable = false }
  area       = "0"
}

resource "vyos_protocols_ospf_interface" "enable_ospf_dum240" {
  depends_on = [vyos_interfaces_dummy.dummy_interface]
  identifier = { interface = "dum240" }
  passive    = { disable = false }
  area       = "0"
}
