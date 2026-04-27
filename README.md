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

The spine routers provide routed underlay reachability.

- 2 x VyOS spine routers
- Bare-metal
- Connected to both physical switches
- Run eBGP underlay sessions toward leaves over ipv6 link-local
- Advertise/learn VTEP loopbacks used for overlay reachability

### Leaf Layer

The leaves are VyOS VMs running on Proxmox.

- 7 x virtual VyOS leaf routers in cluster
- 1 x virtual VyOS leaf router on daily PVE node
- One leaf/VTEP per hypervisor node
- Each leaf connects to both switches and both spines
- Each leaf participates in the VXLAN/EVPN overlay
- Each leaf can host bridge/VLAN/VNI attachment for local workloads

### Border Leaves

Border leaves provide external connectivity.

- Import/export selected VRF routes from external sources
- Provide external routing toward upstream/core/firewall devices via EVPN Type 5
- Leak routes between selected VRFs if desired

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

Recommended pattern:

```text
<router-id>:<vni>
```

Example:

```text
10.255.240.10:9006
10.255.240.11:9006
10.255.240.12:9006
```

This means each VTEP exporting the same VNI still produces unique EVPN routes.

#### Route Target

The RT controls import/export policy.

Recommended simple homelab pattern:

```text
target:<fabric-asn>:<vni>
```

Example:

```text
target:700:9006
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
