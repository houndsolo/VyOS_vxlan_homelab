NOTE1: cannot seem to properly redistribute evpn host routes into ipv4-vpn af? 
Can do ipv4-vpn into VRF:ipv4-unicast into evpn


# VyOS VXLAN Homelab
OpenTofu-driven VyOS VXLAN/EVPN homelab fabric running on a mix of bare-metal routers and virtual VyOS routers on Proxmox.
This repository is used to build and manage a routed underlay, BGP overlay, VXLAN interfaces, bridge/VLAN attachment, VRFs, and EVPN-related configuration for a small spine/leaf fabric.

---

## Current Architecture

### Physical Topology

The physical network uses:

- 2 physical switches
- 2 bare-metal VyOS spine routers (n100 mini pcs)
- 7 virtual VyOS leaf/VTEP routers - one per Physical Proxmox host (beefy am4/am5 computers)
- 2 virtualized border leaves - on Proxmox HA
- Dual-switch connectivity for redundancy
-- My spines only have 4 physical interfaces. I have extended the physical ports of the spines by using switches to connect to downstream leaves
-- Each physical node connects to both switches
-- Spine - Leaf pair for each switch = 4 connections per leaf


Example for node `10`:

| Link | VLAN |
|---|---:|
| switch 1 -> spine 1 -> node 10 | `1110` |
| switch 1 -> spine 2 -> node 10 | `1210` |
| switch 2 -> spine 1 -> node 10 | `2110` |
| switch 2 -> spine 2 -> node 10 | `2210` |

VLAN naming convention:

```text
switch L, spine M, node N -> VLAN LMN
```


### Logical Topology

```text
                         ┌──────────────┐
                         │   Spine 1    │
                         │ Bare-metal   │
                         └──────┬───────┘
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
        ┌─────▼─────┐     ┌─────▼─────┐     ┌─────▼─────┐
        │ Leaf 10   │     │ Leaf 11   │     │ Leaf ...  │
        │ VyOS VM   │     │ VyOS VM   │     │ VyOS VM   │
        └─────▲─────┘     └─────▲─────┘     └─────▲─────┘
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                         ┌──────▼───────┐
                         │   Spine 2    │
                         │ Bare-metal   │
                         └──────────────┘
```

Underlay is done via ipv6 link local and RAs. no addressing configuration done
Overlay peering is built between VTEPs using loopback address.

---

## Components

### Spine Layer

- evpn route reflectors
- no vrfs exist


### Leaf Layer

The leaves are VyOS VMs running on Proxmox.

- 7 x virtual VyOS leaf routers in cluster
- 1 x virtual VyOS leaf router on daily PVE node
- One leaf/VTEP per hypervisor node
- Each leaf connects to both switches and both spines - 4 way ECMP


### Border Leaves

Border leaves provide external connectivity.

- Import/export selected VRF routes from external sources
- Provide external routing toward upstream/core/firewall devices via EVPN Type 5
- Leak routes between selected VRFs

---

## Routing Design

### Underlay

The underlay provides IP reachability between VTEP loopbacks.

Current underlay model:

- IPv6 link-local transport on point-to-point links
- eBGP sessions between spines and leaves
- IPv4 VTEP loopbacks advertised over IPv6 next-hop
- `local-as` behavior used where needed to force eBGP-like behavior
-- could not use local-as for EVPN IBGP peering. Spine RR does not work
```text
node ASN = 700 + node_id
```

So the only IP address configured per Spine/Leaf (other than anycast gateways) is the loopback(dummy) interface for Vtep peering
ezpz

### Overlay

The overlay provides VXLAN/EVPN control-plane reachability.

Current overlay model:

- iBGP between VTEP loopbacks
- Common overlay AS: `700`
- VTEP loopbacks use `10.255.240.0/24`
- Loopback format: `10.255.240.<node_id>/32`

---

## EVPN/VXLAN Design Notes

#### Route Distinguisher

The RD makes routes unique in BGP.
if we used common RD, multipath would not happen
Unique RD Per switch!

Recommended pattern:

```text
<router-id>:<vni> 
```

This means each VTEP exporting the same VNI still produces unique EVPN routes.

#### Route Target

The RT controls import/export policy.
Single RT per L2VNI / L3VNI
```text
target:<fabric-asn>:<vni>
```


For a single shared L2/L3 segment, all participating VTEPs can export and import the same RT.

Example:

```text
export RT: target:700:9006
import RT: target:700:9006
```

For more advanced multi-VRF or border-leaf designs, a VRF can import multiple RTs.

Example:

```text
VRF lylat_service imports:
  - target:700:9006
  - target:700:9010
  - target:700:9020
```
---

### Single Vxlan Device issues
-- attempted to use Single Vxlan Device(SVD) https://blog.vyos.io/evpn-vxlan-enhancements-introducing-single-vxlan-device-support
This did not work seamlessly:
Non-VyOS API change required for anycast gateway
- [Anycast gateway with SVD - FRR docs](https://docs.frrouting.org/en/latest/evpn.html#anycast-gateways-with-single-vxlan-device)
- [VyOS Issue 1](https://vyos.dev/T5189)
- [VyOS Issue 2](https://vyos.dev/T7274) - try this fix?

Cannot figure out how to map L3VNI to a SVD. seem to need a separate VXLAN device to defiine L3VNI.

---

## OpenTofu Module Layout

The leaf fabric configuration is split so normal leaves and border leaves share one implementation for the common base fabric logic and one implementation for the common VXLAN/bridge logic, while keeping role-specific and border-leaf-specific VRF/BGP policy separate:

```text
configure_fabric/
  leaf_common/      # shared system, underlay, BGP underlay, and EVPN overlay config
  leaf_l2_common/   # shared VXLAN interfaces, bridges, and SVIs
  leaves/           # normal leaf wrapper, normal leaf VRF/L3VNI policy, and host/VM access on eth3
  border_leaves/    # border leaf wrapper, BL-specific VRF/L3VNI policy, and external L3 connectivity
```

`leaf_common` owns the common resources for system settings, underlay interfaces, BGP underlay, and the BGP EVPN overlay. Both `leaves` and `border_leaves` instantiate this shared module first.

`leaves/40_vrf_l3vni.tf` and `border_leaves/40_vrf_l3vni.tf` intentionally remain separate because border leaves have different VRF policy and BGP settings than normal leaves.

`leaf_l2_common` owns the shared VXLAN interfaces, bridges, and SVIs. Both role wrappers instantiate it after their role-specific `40_vrf_l3vni.tf` resources, so the shared L2/VXLAN resources can still be reused without forcing normal leaves and border leaves to share incompatible VRF/BGP policy.

Normal leaves keep host/VM access resources in `configure_fabric/leaves/70_host_access.tf`, including the VM-facing Ethernet interface, VLAN subinterfaces, and bridge membership.

Border leaves keep external L3 resources in `configure_fabric/border_leaves/80_external_l3.tf`, including the external Ethernet interface, VRF VIFs, router advertisements, and per-VRF BGP neighbors/peer groups from `external_l3`.

Normal leaves and border leaves still share the same base BGP/EVPN underlay/overlay implementation and the same VXLAN/L2VNI bridge/SVI implementation, while preserving unique VRF/L3VNI policy where border leaves differ.

### Refactor and state notes

This refactor intentionally changes OpenTofu resource addresses for shared resources because they moved under nested shared modules inside both role wrappers. For example, a former address like:

```text
module.leaf_vms["node"].vyos_protocols_bgp.enable_bgp
```

is now under:

```text
module.leaf_vms["node"].module.leaf_common.vyos_protocols_bgp.enable_bgp
```

and shared VXLAN/bridge resources are now under:

```text
module.leaf_vms["node"].module.leaf_l2_common.vyos_interfaces_vxlan.vxlan_interfaces_L2
```

Border-leaf shared resources follow the same pattern under `module.border_leaves[*].module.leaf_common` and `module.border_leaves[*].module.leaf_l2_common`. The `40_vrf_l3vni.tf` resources remain directly in the role modules so normal leaf and border-leaf VRF/BGP policy can stay different. If preserving an existing state file matters, use `tofu state mv` for moved shared resources or recreate the lab state from scratch.
