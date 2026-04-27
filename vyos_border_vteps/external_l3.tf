resource "vyos_protocols_bgp_neighbor" "fw_wan_vpnv4_neighbor" {
  depends_on = [vyos_protocols_bgp_peer_group.peer_group_spine_underlay]
  identifier = { neighbor = "10.255.240.255" }
  remote_as = 420
  address_family = {
    ipv4_vpn = {
      soft_reconfiguration = {inbound = true}
    }
  }
  update_source = local.vxlan_source_interface
  ebgp_multihop = 255
}
