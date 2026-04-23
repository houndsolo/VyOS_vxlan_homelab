resource "vyos_system" "host_parameters" {
  domain_name = var.dns.domain_name
  domain_search = var.dns.domain_search
  name_server = var.dns.name_servers
  host_name = var.host_node.hostname
}

resource "vyos_system_ip_multipath" "set_multipath" {
  depends_on = [vyos_system.host_parameters]
  ignore_unreachable_nexthops = true
  layer4_hashing = true
}

resource "vyos_interfaces_dummy" "dummy_interface" {
  depends_on = [vyos_system_ip_multipath.set_multipath]
  identifier = {dummy = "dum0"}
  address = [
    local.dum0_network
  ]
  mtu = "9169"
}

resource "vyos_interfaces_ethernet" "link_to_spines" {
  depends_on = [vyos_interfaces_dummy.dummy_interface]
  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }

  identifier = { ethernet = "eth${tostring(each.value.eth_id)}" }
  description = "p2p link to spine"
  address     = [each.value.host_ip]
  mtu = "9169"

  lifecycle {
    ignore_changes = [
      hw_id
    ]
  }
}

resource "vyos_interfaces_ethernet" "link_to_vms" {
  depends_on = [vyos_interfaces_ethernet.link_to_spines]

  identifier = { ethernet = "eth${tostring(var.spines + 1)}" }
  description = "link to vms"
  mtu = "9119"
  lifecycle {
    ignore_changes = [
      hw_id
    ]
  }
}

resource "vyos_protocols_ospf" "ospf_config" {
  depends_on = [vyos_interfaces_ethernet.link_to_vms]
  maximum_paths = 4
  passive_interface = "default"
}

resource "vyos_protocols_ospf_interface" "ospf_interface_config" {
  depends_on = [vyos_protocols_ospf.ospf_config]
  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }

  identifier = { interface = "eth${tostring(each.value.eth_id)}" }
  area = 0
  network = "point-to-point"
  bfd = {}

  #turn off passive interface
  passive = {
    disable = true
  }

}

resource "vyos_protocols_ospf_interface" "ospf_interface_dum0_config" {
  depends_on = [vyos_protocols_ospf_interface.ospf_interface_config]

  identifier = { interface = "dum0" }
  area = 0

}

resource "vyos_protocols_pim_interface" "pim_interface_enable" {
  depends_on = [vyos_protocols_ospf_interface.ospf_interface_dum0_config]
  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }
  identifier = { interface = "eth${tostring(each.value.eth_id)}" }
  igmp = {}
}

resource "vyos_protocols_pim_interface" "pim_dum0" {
  depends_on = [vyos_protocols_pim_interface.pim_interface_enable]
  identifier = { interface = "dum0" }
  igmp = {}
}

#resource "vyos_protocols_pim_interface_igmp_join" "link_to_spine_igmp" {
#  depends_on = [vyos_protocols_pim_interface.pim_dum0]
#  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }
#  identifier = {
#    interface = "eth${tostring(each.value.eth_id)}"
#    join = "225.0.0.69"
#  }
#}
#resource "vyos_protocols_pim_interface_igmp_join" "dum0_igmp" {
#  depends_on = [vyos_protocols_pim_interface_igmp_join.link_to_spine_igmp]
#  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }
#  identifier = {
#    interface = "dum0"
#    join = "225.0.0.69"
#  }
#}

resource "vyos_protocols_pim_rp_address" "set_rp" {
  depends_on = [vyos_protocols_pim_interface.pim_dum0]
#  depends_on = [vyos_protocols_pim_interface_igmp_join.dum0_igmp]

  identifier = { address = var.anycast_rp_address }
  group = var.rp_groups

}

resource "vyos_protocols_bfd_peer" "spine_bfd_peers" {
  depends_on = [vyos_protocols_pim_rp_address.set_rp]
  for_each = { for link in local.link_to_spines : tostring(link.eth_id) => link }
  identifier = { peer = each.value.peer_ip }
  source = { interface = "eth${tostring(each.value.eth_id)}" }
  interval = {
    multiplier  = 3
    reeive      = 100
    transmit  = 100
  }
}
