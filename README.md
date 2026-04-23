# OpenTofu VXLAN Homelab

A network automation project using OpenTofu 1.9 to deploy  VXLAN VMs on hypervisors for other virtual machines to connect to.


## 🏗️ Architecture
Physical topology
Hypervisors connected to each Spine (vmbr4001,vmbr4002), and to 1 Leaf(vmbr100)
VyOS Vtep is connected to each Spine

VMs are connected to either the VyOS Vtep(vmbr4000), or to the Physical 9300 Leaf(vmbr100)

### Hardware Components
- **Spine Layer**
  - 2 x Cisco Catalyst 9300 switches
  - Running IOS-XE 17.16.01

- **Leaf Layer**
  - 2 x Cisco Catalyst 9300 switches
  - 7 x Virtual VyOS routers (on Proxmox)
  - Running VyOS 1.5-rolling-202402060022


### Addressing Scheme
- **Underlay Network**
  - OSPF Point-to-point links: `10.240.[leaf][spine].0/31`

- **Overlay Network**
  - iBGP Loopback interfaces: `10.240.[254-255].[id]`
  - MSDP peering: `10.240.253.[id]`

## 📁 Project Structure

```
├── proxmox_vteps
│   ├── vars.tf
│   ├── versions.tf
│   └── create_vms.tf
├── vyos_vteps
│   ├── versions.tf
│   ├── vyos_bgp.tf
│   ├── vyos_init.tf
│   └── vyos_vxlan.tf
├── README.md
├── debug.log
├── main.tf
├── passwords.tf
├── providers.tf
├── vars.tf
├── versions.tf

```

## 🚀 Getting Started

### Prerequisites
- OpenTofu 1.9 or later
  - this uses for_each providers, which terraform does not have
- VyOS 1.5-rolling-202402060022
- Proxmox VE for virtual routers

