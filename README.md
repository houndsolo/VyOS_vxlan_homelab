# VyOS VXLAN Homelab

OpenTofu/Terraform automation for building and configuring a VyOS/FRR EVPN-VXLAN homelab fabric.

This repository is focused on a lab fabric with VyOS VTEP leaves, MikroTik CRS326 spine/route-reflector nodes, Proxmox-hosted VyOS VMs, border leaves, VRFs, L2VNIs, L3VNIs, and EVPN route-target based segmentation.


## What this builds

At the top level, the repo calls two modules:

- `create_fabric_vms` — creates VyOS VTEP VMs on Proxmox.
- `configure_fabric` — configures VyOS fabric nodes.


The current fabric model includes:

- Two Mikrotik CRS 326 spines. (need to add config). Spines are dumb and ezpz
    - requires ROS 7.24.1 or greater due to EVPN RR bug
- Standard leaf VTEP nodes.
- Border leaf nodes.
- Optional fabric-extension leaves.
- A separate `greatfox` Proxmox target.
- Multiple VRFs/L3VNIs.
- Multiple L2VNIs with anycast gateways.

## Current design notes

### Underlay

Leaf nodes run BGP AS `700` globally and use per-node underlay local-AS values derived from the node ID:

```hcl
underlay_local_as = 700 + var.node.id
bgp_system_as    = 700
```

The underlay peers toward the spines with interface-based IPv6-only BGP:

```hcl
neighbor = each.value.uplink_if
interface.v6only.peer_group = "spine_underlay"
```

The underlay peer-group enables extended nexthop and uses `remote_as = "external"`.

### Overlay

The EVPN overlay uses:

- `address-family l2vpn-evpn`
- `advertise_all_vni`
- `advertise_svi_ip`
- head-end replication
- `rt_auto_derive = false`
- overlay peer-group `spine_overlay`
- update source `dum240`

The current EVPN overlay neighbors are the spine IPv6 loopbacks from `var.fabric.spines[*].v6_peering`.

Example spine loopbacks from `terraform.tfvars`:

```hcl
rtr1 = { id = 1, uplink_if = "eth1", v6_peering = "fd69:255:240::1" }
rtr2 = { id = 2, uplink_if = "eth2", v6_peering = "fd69:255:240::2" }
```

### VTEP addressing

Leaf VTEP loopbacks are generated from the node ID:

```hcl
vxlan_loopback_net    = "10.255.240.${var.node.id}"
vxlan_loopback_v6_net = "fd69:255:240::${var.node.id}"
vxlan_source_interface = "dum240"
```

### VXLAN defaults

Current VXLAN defaults:

```hcl
mtu                = 9119
outer_mtu          = 9189
nolearning         = true
neighbor_suppress  = false
vni_filter         = false
```

### VRFs and VNIs

Current L3VNIs in `terraform.tfvars`:

| L3VNI | VRF | Table | External VLAN |
|---:|---|---:|---:|
| 6200 | `lylat_infra` | 700 | 62 |
| 6600 | `lylat_service` | 1000 | 66 |
| 6900 | `lylat_lan` | 1337 | 69 |

Current L2VNIs:

| VLAN | L2VNI | VRF | Anycast gateway |
|---:|---:|---|---|
| 2 | 9002 | `lylat_infra` | `10.2.0.5/16` |
| 6 | 9006 | `lylat_service` | `10.6.0.5/16` |
| 8 | 9008 | `lylat_service` | `10.8.0.5/16` |
| 9 | 9009 | `lylat_lan` | `10.9.0.5/16` |

## Repository layout

```text
.
├── main.tf
├── versions.tf
├── vars.tf
├── terraform.tfvars
├── configure_fabric/
│   ├── main.tf
│   ├── providers.tf
│   ├── vars.tf
│   ├── leaves/
│   └── border_leaves/
└── create_fabric_vms/
    ├── main.tf
    ├── providers.tf
    ├── vars.tf
    └── proxmox_vteps/
```

## Providers

Defined provider requirements:

```hcl
terraform {
  required_providers {
    vyos = {
      source  = "registry.terraform.io/echowings/vyos-rolling"
      version = "0.21.202507150"
    }
    proxmox = {
      source  = "local/mechanic/proxmox"
      version = "0.108.0"
    }
  }
}
```

The VyOS provider connects to nodes at:

```text
https://10.20.10.<node-id>
```

The Proxmox providers currently point at:

```text
https://10.20.7.11:8006
https://10.20.7.20:8006  # greatfox alias
```

## Required secrets

- `vyos_key` — VyOS HTTPS API key.
- `pve_api_token` — Proxmox API token for the primary cluster.
- `gf_api_token` — Proxmox API token for the `greatfox` target.


## Customizing the lab

Most lab-specific intent lives in `terraform.tfvars`.

Edit the `fabric` object to add or remove nodes:

```hcl
fabric = {
  spines = {}
  leaves = {}
  fabric_ext_leaves = {}
  border_leaves = {}
  leaves_greatfox = {}
}
```

Edit the `vnis.l3` object to add or remove VRFs, L3VNIs, route-targets, external L3 vlan, and nested L2VNIs.

Each L2VNI can define:

- VLAN ID
- VNI
- anycast gateway IP/CIDR
- anycast MAC
- default-gateway advertisement
- SVI IP advertisement
- IPv4 unicast export

## Operational assumptions

This repo assumes:

- VyOS nodes are reachable over HTTPS on the management network.
- VyOS API keys already exist.
- Proxmox API tokens already exist.
- SSH access to Proxmox uses `root` and `~/.ssh/id_rsa`.
- The local Proxmox provider source `local/mechanic/proxmox` is available to OpenTofu/Terraform.
- The lab uses ULA IPv6 VTEP/overlay addressing under `fd69:255:240::/64`.
- MikroTik spines handle EVPN route-reflection outside this repo.

## Useful checks

On VyOS/FRR leaves:

```bash
show bgp summary
show bgp ipv4 vpn
show bgp vrf lylat_lan ipv4
show bgp l2vpn evpn summary
show bgp l2vpn evpn route
show ip route vrf all
monitor traffic interface any filter 'port not 22'
```

On MikroTik spines:

```routeros
/routing/bgp/session/print detail
/routing/route/print detail where afi=evpn
/routing/bgp/advertisements/print detail
```

## Status

Current direction: MikroTik spines are used as EVPN route reflectors, and VyOS leaves peer EVPN overlay to the spine IPv6 loopbacks.

Older MPLS/VPNv4 experiments appear to have been removed or disabled in favor of the current EVPN-focused workflow.
