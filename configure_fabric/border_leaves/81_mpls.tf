locals {
  mpls_loopback        = "10.255.230.${var.node.id}/32"
  mpls_loopback_net    = "10.255.230.${var.node.id}"
  mpls_loopback_v6     = "fd69:255:230::${var.node.id}/128"
  mpls_loopback_net_v6 = "fd69:255:230::${var.node.id}"
  mpls_interfaces = [
    "eth3",
  ]
}



resource "vyos_interfaces_dummy" "dummy_interface_mpls" {
  identifier = { dummy = "dum469" }
  address = [
    local.mpls_loopback_v6,
  ]
  mtu         = var.vxlan.outer_mtu
}

resource "vyos_protocols_mpls" "mpls_interfaces" {
  depends_on = [
  ]
  interface = local.mpls_interfaces
}

resource "vyos_protocols_mpls_ldp_interface" "ldp_router_interfaces" {
  depends_on = [
  ]
  for_each   = toset(local.mpls_interfaces)
  identifier = { interface = each.value }
}

resource "vyos_protocols_mpls_ldp" "ldp_router_id" {
  depends_on = [
  ]
  router_id = local.mpls_loopback_net
}


resource "vyos_protocols_mpls_ldp_discovery" "ldp_discovery" {
  depends_on = [
  ]
  transport_ipv6_address = local.mpls_loopback_net_v6
}
