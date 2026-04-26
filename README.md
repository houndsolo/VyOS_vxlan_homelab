# OpenTofu VXLAN Homelab

A network automation project using OpenTofu 1.9+ to deploy  VXLAN VMs on hypervisors for other virtual machines to connect to.


-- note
fdb entry  needs to be added for anycast gateway -- only for SingleVxlanDevice setups
`ansible -i hosts.yml -a 'bash  -c  "sudo bridge fdb replace 0e:00:00:10:00:80 dev br0 self local"' vteps`


## 🏗️ Architecture
Physical topology
2 switches for connectivity [1 & 2]
7 Hypervisors connected to both switches [nodes 10,11,12,13,14,17,21]
2 virtuaized border leaves on nodes 10, 21
2 Spines connected to both switches [1 & 2]

Each Hypervisor then has 1 connection per Switch per Spine - 4 connections per hypervisor.
ex node 10)
sw1s1v10 - 1110
sw1s2v10 - 1210
sw2s1v10 - 2110
sw2s2v10 - 2210

### Hardware Components
- **Spine Layer**
  - 2 x VyOS routers (on bare-metal)
  - Running VyOS 1.5-rolling-202402060022

- **Leaf Layer**
  - 7 x Virtual VyOS routers (on Proxmox)
  - Running VyOS 1.5-rolling-202402060022


### Addressing Scheme
- **Underlay Network**
  - ipv6 link-local, with ipv4 dum240 loopback advertised over ipv6 next hop
  - using local-as to force eBGP behavior, AS 700 + id

- **Overlay Network**
  - iBGP Loopback interfaces: `10.255.240.[id]`
  - AS 700
