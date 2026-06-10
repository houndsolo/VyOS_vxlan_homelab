#output "fabric_inventory" {
#  description = "Structured spine/leaf inventory with VM IDs, management IPs, loopbacks, and BGP ASNs."
#  value       = local.fabric_nodes
#}
#
#output "l2_vni_matrix" {
#  description = "Structured L2VNI to VRF mapping."
#  value       = local.l2_vnis_sorted
#}
#

output "fabric_inventory_pretty" {
  description = "Human-readable spine/leaf inventory."
  value = join("\n", concat(
    [
      "Name      Role             ID  Hostname            VM   VM ID  Hypervisor  Mgmt IP       Loopback             Underlay ASN",
      "--------  ---------------  --  ------------------  ---  -----  ----------  ------------  -------------------  ------------",
    ],
    [
      for node in local.fabric_nodes_sorted : format(
        "%-8s  %-15s  %2d  %-18s  %-3s  %-5s  %-10s  %-12s  %-19s  %d",
        node.name,
        node.role,
        node.id,
        node.hostname,
        node.vm ? "yes" : "no",
        node.vm_id,
        node.hypervisor_node,
        node.mgmt_ip,
        node.loopback,
        node.underlay_asn,
      )
    ]
  ))
}

output "vrf_vni_matrix_pretty" {
  description = "Human-readable VRF/L3VNI/L2VNI matrix."
  value = join("\n", concat(
    [
      "VRF            L3VNI  Table  Ext VLAN  L2 VLANs -> L2VNIs / Anycast GW",
      "-------------  -----  -----  --------  ---------------------------------",
    ],
    [
      for vrf in local.l3_vnis_sorted : format(
        "%-13s  %5d  %5d  %-8s  %s",
        vrf.vrf,
        vrf.vni,
        vrf.vrf_table,
        try(vrf.ext_l3_vlan, null) == null ? "-" : tostring(vrf.ext_l3_vlan),
        join(", ", [
          for vlan_key in sort(keys(vrf.l2)) : format(
            "vlan%s=vni%d gw %s/%d",
            vlan_key,
            vrf.l2[vlan_key].vni,
            vrf.l2[vlan_key].anycast_gw_ip,
            vrf.l2[vlan_key].anycast_gw_cidr,
          )
        ])
      )
    ]
  ))
}

