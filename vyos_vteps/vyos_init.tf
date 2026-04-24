resource "vyos_system" "host_parameters" {
  domain_name = var.dns.domain_name
  domain_search = var.dns.domain_search
  name_server = var.dns.name_servers
  host_name = local.hostname
}

resource "vyos_system_ip_multipath" "set_multipath" {
  depends_on = [vyos_system.host_parameters]
  ignore_unreachable_nexthops = true
  layer4_hashing = true
}

resource "vyos_interfaces_dummy" "dummy_interface" {
  depends_on = [vyos_system_ip_multipath.set_multipath]
  identifier = {dummy = local.vxlan_source_interface}
  address = [
    local.vxlan_loopback
  ]
  mtu = "9169"
}

resource "vyos_interfaces_ethernet" "link_to_spines_switch1" {
  depends_on = [vyos_interfaces_dummy.dummy_interface]
  #  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }

  identifier = { ethernet = "eth1" }
  description = "p2p-sw1"
  mtu = "9169"

    lifecycle {
      ignore_changes = [
        hw_id
      ]
    }
}

resource "vyos_interfaces_ethernet_vif" "link_to_spines_vifs_switch1" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines_switch1]
  for_each = var.spines

  identifier = {
    ethernet = "eth1"
    vif = 1000 + 100 * each.value.id + var.node.id
  }
  ipv6 = {}
  description = "p2p-spine-${each.value.id} - vlan${1000 + 100 * each.value.id + var.node.id}-sw1"
  mtu = "9169"

}

resource "vyos_interfaces_ethernet" "link_to_spines_switch2" {
  depends_on = [vyos_interfaces_dummy.dummy_interface]
  #  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }

  identifier = { ethernet = "eth2" }
  description = "p2p-sw2"
  mtu = "9169"

    lifecycle {
      ignore_changes = [
        hw_id
      ]
    }
}

resource "vyos_interfaces_ethernet_vif" "link_to_spines_vifs_switch2" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines_switch1]
  for_each = var.spines

  identifier = {
    ethernet = "eth2"
    vif = 2000 + 100 * each.value.id + var.node.id
  }
  ipv6 = {}
  description = "p2p-spine-${each.value.id} - vlan${2000 + 100 * each.value.id + var.node.id}-sw2"
  mtu = "9169"

}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth1" {
  for_each = var.spines
  identifier = { interface = "eth1.${1000+100*each.value.id+var.node.id}" }
}

resource "vyos_service_router_advert_interface" "enable_ipv6_ra_underlay_eth2" {
  for_each = var.spines
  identifier = { interface = "eth2.${2000+100*each.value.id+var.node.id}" }
}

resource "vyos_interfaces_ethernet" "link_to_vms" {
  depends_on = [vyos_interfaces_ethernet_vif.link_to_spines_vifs_switch2]
  identifier = { ethernet = "eth3" }
  description = "link to vms"
  mtu = "9119"
  lifecycle {
    ignore_changes = [
      hw_id
    ]
  }
}
