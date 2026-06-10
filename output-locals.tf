locals {
  fabric_nodes = merge(
    {
      for name, node in var.fabric.spines : name => {
        name            = name
        role            = "spine"
        hostname        = "SPINE-${node.id}"
        id              = node.id
        vm              = false
        vm_id           = "-"
        hypervisor_node = "bare-metal"
        mgmt_ip         = "10.20.10.${node.id}"
        api_endpoint    = "https://10.20.10.${node.id}"
        loopback        = "10.255.240.${node.id}/32"
        underlay_asn    = 700 + node.id
        overlay_asn     = 700
      }
    },
    {
      for name, node in var.fabric.leaves : name => {
        name            = name
        role            = "leaf"
        hostname        = "vtep-${name}"
        id              = node.id
        vm              = node.is_vm
        vm_id           = node.is_vm ? tostring(700 + node.id) : "-"
        hypervisor_node = node.hypervisor_node
        mgmt_ip         = "10.20.10.${node.id}"
        api_endpoint    = "https://10.20.10.${node.id}"
        loopback        = "10.255.240.${node.id}/32"
        underlay_asn    = 700 + node.id
        overlay_asn     = 700
      }
    },
    {
      for name, node in var.fabric.fabric_ext_leaves : name => {
        name            = name
        role            = "fabric-ext-leaf"
        hostname        = "vtep-fabric-ext-${node.id}"
        id              = node.id
        vm              = node.is_vm
        vm_id           = node.is_vm ? tostring(700 + node.id) : "-"
        hypervisor_node = node.hypervisor_node
        mgmt_ip         = "10.20.10.${node.id}"
        api_endpoint    = "https://10.20.10.${node.id}"
        loopback        = "10.255.240.${node.id}/32"
        underlay_asn    = 700 + node.id
        overlay_asn     = 700
      }
    },
    {
      for name, node in var.fabric.border_leaves : name => {
        name            = name
        role            = "border-leaf"
        hostname        = "vtep-border-${node.id}"
        id              = node.id
        vm              = node.is_vm
        vm_id           = node.is_vm ? tostring(700 + node.id) : "-"
        hypervisor_node = node.hypervisor_node
        mgmt_ip         = "10.20.10.${node.id}"
        api_endpoint    = "https://10.20.10.${node.id}"
        loopback        = "10.255.240.${node.id}/32"
        underlay_asn    = 700 + node.id
        overlay_asn     = 700
      }
    },
    {
      for name, node in var.fabric.leaves_greatfox : name => {
        name            = name
        role            = "leaf-greatfox"
        hostname        = "vtep-${name}"
        id              = node.id
        vm              = node.is_vm
        vm_id           = node.is_vm ? tostring(700 + node.id) : "-"
        hypervisor_node = node.hypervisor_node
        mgmt_ip         = "10.20.10.${node.id}"
        api_endpoint    = "https://10.20.10.${node.id}"
        loopback        = "10.255.240.${node.id}/32"
        underlay_asn    = 700 + node.id
        overlay_asn     = 700
      }
    }
  )

  fabric_node_sort_keys = sort([
    for node in values(local.fabric_nodes) : format("%03d-%s", node.id, node.name)
  ])

  fabric_nodes_sorted = [
    for key in local.fabric_node_sort_keys : local.fabric_nodes[substr(key, 4, length(key) - 4)]
  ]

  l3_vnis_sorted = [
    for key in sort(keys(var.vnis.l3)) : var.vnis.l3[key]
  ]

  l2_vnis_sorted = flatten([
    for l3 in local.l3_vnis_sorted : [
      for vlan_key in sort(keys(l3.l2)) : merge(l3.l2[vlan_key], {
        parent_vrf = l3.vrf
        parent_vni = l3.vni
      })
    ]
  ])
}

