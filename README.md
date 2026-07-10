# VyOS VXLAN Homelab

OpenTofu automation for building and configuring a VyOS/FRR EVPN-VXLAN homelab fabric.

This repository is focused on a lab fabric with VyOS VTEP leaves, MikroTik CRS326 spine/route-reflector nodes, Proxmox-hosted VyOS VMs, border leaves, VRFs, L2VNIs, L3VNIs, and EVPN route-target based segmentation.

## What this builds

At the top level, the repo calls two modules:

- `create_fabric_vms` — creates VyOS VTEP VMs on Proxmox.
- `configure_fabric` — configures VyOS fabric nodes.

The current fabric model includes:

- Two MikroTik CRS326 spines. Spines are handled outside this repo and require RouterOS 7.24.1 or greater due to an EVPN route-reflector bug.
- Standard leaf VTEP nodes.
- Border leaf nodes.
- Optional fabric-extension leaves.
- A separate `greatfox` Proxmox target.
- Multiple VRFs/L3VNIs.
- Multiple L2VNIs with anycast gateways.

## Source of truth

`*.auto.tfvars` files are intended to be the main source of truth for lab-specific values. In this repo, `fabric.auto.tfvars` defines the fabric inventory, shared fabric defaults, VXLAN defaults, BGP EVPN/L2VPN defaults, DNS, and VNI intent.

Shared fabric-wide values live under `fabric.defaults`:

```hcl
fabric = {
  defaults = {
    bgp_system_as                     = 700
    underlay_local_as_base            = 700
    ipv4_loopback_prefix              = "10.255.240.0/24"
    ipv6_underlay_prefix              = "fd69:255:240::/64"
    vxlan_source_interface            = "dum240"
    l2_service_bridge_id              = 9000
    vyos_mgmt_prefix                  = "10.20.10.0/24"
    vyos_mgmt_cidr                    = 16
    vyos_provider_default_timeouts    = 1
    vyos_provider_disable_verify      = true
    vyos_overwrite_existing_on_create = true
  }
}
```

Important derived behavior:

- The fabric BGP system AS defaults to `fabric.defaults.bgp_system_as` (`700`).
- Per-node underlay local-AS values are derived as `fabric.defaults.underlay_local_as_base + node.id`.
- IPv4 loopbacks are generated with `cidrhost(fabric.defaults.ipv4_loopback_prefix, node.id)` and remain `10.255.240.<id>/32`.
- The IPv6 underlay/VTEP prefix is declared once as `fd69:255:240::/64` in `fabric.defaults.ipv6_underlay_prefix`.
- IPv6 VTEP loopbacks, generated VXLAN peers, and spine EVPN overlay peering addresses are derived with `cidrhost(fabric.defaults.ipv6_underlay_prefix, node.id)`.
- VyOS API endpoints are derived from `fabric.defaults.vyos_mgmt_prefix`, for example `https://${cidrhost(fabric.defaults.vyos_mgmt_prefix, node.id)}`.
- `configure_fabric/vars.tf` centralizes derived per-node values before passing them to leaf and border-leaf modules, keeping child module variable files focused on input contracts.

## Fabric defaults

### BGP EVPN/L2VPN defaults

BGP EVPN/L2VPN defaults live in `fabric.bgp_l2vpn`:

```hcl
bgp_l2vpn = {
  her              = true
  flooding_disable = false
  advertise_svi    = true
  advertise_vni    = true
  rt_auto_derive   = false
}
```

These values are passed from the top-level fabric object into the leaf and border-leaf modules.

### VXLAN defaults

VXLAN defaults live in `fabric.vxlan`:

```hcl
vxlan = {
  mtu                       = 9119
  outer_mtu                 = 9189
  disable_forwarding        = false
  disable_arp_filter        = false
  enable_arp_accept         = false
  enable_arp_announce       = false
  enable_directed_broadcast = false
  enable_proxy_arp          = false
  proxy_arp_pvlan           = false
  external                  = false
  neighbor_suppress         = false
  nolearning                = true
  vni_filter                = false
}
```

### L2 service bridge

`fabric.defaults.l2_service_bridge_id` controls the shared L2 service bridge ID. The default `9000` preserves the existing `br9000` bridge naming.

## Adding nodes

### Add a spine

Add a new entry under `fabric.spines` with an `id` and `uplink_if` only:

```hcl
spines = {
  rtr3 = { id = 3, uplink_if = "eth3" }
}
```

The overlay peering address is generated from `fabric.defaults.ipv6_underlay_prefix` and the spine ID, so spine entries only need fabric inventory fields such as `id` and `uplink_if`.

### Add a leaf

Add a new entry under `fabric.leaves`:

```hcl
leaves = {
  newleaf = { hypervisor_node = "newleaf", id = 21, is_vm = true }
}
```

The leaf hostname, BGP local-AS, management endpoint, IPv4 loopback, IPv6 VTEP loopback, and VXLAN peer loopback are derived from the node ID and fabric defaults.

### Add a border leaf

Add a new entry under `fabric.border_leaves`:

```hcl
border_leaves = {
  border-3 = { id = 20, is_vm = false }
}
```

Border leaves use the same derived addressing and BGP defaults as standard leaves. Border-specific external L3 settings remain in `external_l3`.

## VRFs and VNIs

Edit the `vnis.l3` object in `fabric.auto.tfvars` to add or remove VRFs, L3VNIs, route-targets, external L3 VLANs, and nested L2VNIs.

Each L2VNI can define:

- VLAN ID
- VNI
- Anycast gateway IP/CIDR
- Anycast MAC
- Default-gateway advertisement
- SVI IP advertisement
- IPv4 unicast export

## Repository layout

```text
.
├── main.tf
├── versions.tf
├── vars.tf
├── fabric.auto.tfvars
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

VyOS provider endpoints, certificate verification, default timeouts, and overwrite-on-create behavior are controlled by `fabric.defaults`. Manual binding overrides remain in provider blocks because they are provider implementation details rather than lab intent.

The Proxmox providers currently point at:

```text
https://10.20.7.11:8006
https://10.20.7.20:8006  # greatfox alias
```

## Required secrets

- `vyos_key` — VyOS HTTPS API key.
- `pve_api_token` — Proxmox API token for the primary cluster.
- `gf_api_token` — Proxmox API token for the `greatfox` target.

Do not commit real secret tfvars, `.terraform/`, provider binaries, or state files.

## Formatting and validation

Run formatting from the repository root:

```bash
tofu fmt -recursive
```

Run validation when provider plugins and required variable values are available:

```bash
tofu validate
```

If validation fails because local provider plugins, API secrets, or environment-specific files are unavailable, fix the environment or document the exact missing dependency before merging.

## Operational assumptions

This repo assumes:

- VyOS nodes are reachable over HTTPS on the management network derived from `fabric.defaults.vyos_mgmt_prefix`.
- VyOS API keys already exist.
- Proxmox API tokens already exist.
- SSH access to Proxmox uses `root` and `~/.ssh/id_rsa`.
- The lab uses ULA IPv6 VTEP/overlay addressing under `fabric.defaults.ipv6_underlay_prefix` (`fd69:255:240::/64` by default).
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

Current direction: MikroTik spines are used as EVPN route reflectors, and VyOS leaves peer EVPN overlay to the spine IPv6 loopbacks derived from the shared IPv6 underlay/VTEP prefix.
External L3 connectivity is only working via:

- IPv4-unicast per-VRF peering over IPv6 link-local.
- IPv4 VPN with IPv4 point-to-point plus MPLS/LDPv4/OSPF underlay through a P router.
