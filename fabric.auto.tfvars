fabric = {
  evpn_rr = {
    evpn-rr-1 = { hypervisor_node = "titania", id = 100, is_vm = true }
    evpn-rr-2 = { hypervisor_node = "fortuna", id = 200, is_vm = true }
  }
  spines = {
    #mikrotik 326
    rtr1 = { id = 1 , uplink_if = "eth1", v6_peering = "fd69:255:240::1"}
    #mikrotik 326
    rtr2 = { id = 2 , uplink_if = "eth2", v6_peering = "fd69:255:240::2"}
  }

  leaves = {
    fichina = { hypervisor_node = "fichina", id = 11, is_vm = true }
    macbeth = { hypervisor_node = "macbeth", id = 12, is_vm = true }
    titania = { hypervisor_node = "titania", id = 13, is_vm = true }
    zoness  = { hypervisor_node = "zoness",  id = 14, is_vm = true }
    fortuna = { hypervisor_node = "fortuna", id = 15, is_vm = true }
    eldarad = { hypervisor_node = "eldarad", id = 16, is_vm = true }
    venom   = { hypervisor_node = "venom",   id = 17, is_vm = true }
  }

  fabric_ext_leaves = {
    fabric-1 = {
      hypervisor_node  = "venom", id = 31, is_vm = true
      underlay_bridges = ["vmbr4001", "vmbr4002", "vmbr100"]
    }
    #fabric-2 = {
    #  hypervisor_node  = "eldarad", id = 32, is_vm = true
    #  underlay_bridges = ["vmbr4001", "vmbr4002", "vmbr100"]
    #}
  }

  border_leaves = {
    # n100 mini pc
    border-1 = { id = 18, is_vm = false }
    # n100 mini pc
    border-2 = { id = 19, is_vm = false }
  }

  leaves_greatfox = {
    greatfox = {
      hypervisor_node  = "greatfox"
      id               = 20
      is_vm            = true
      #underlay_bridges = ["vmbr4001", "vmbr4002", "vmbr4000"]
    }
  }
}

dns = {
  #name_servers  = ["10.8.6.9"]
  name_servers  = ["1.1.1.1"]
  domain_name   = "lylat.space"
  domain_search = ["lylat.space"]
}

vnis = {
  l3 = {
    6200 = {
      vni       = 6200
      vrf       = "lylat_infra"
      vrf_table = 700

      ipv4_rt_imports = "700:6600"
      ipv4_rt_exports = "700:6200"

      BL_ipv4_rt_imports = "420:666 420:77"
      BL_ipv4_rt_exports = "700:6200"

      export_vpn_ipv4 = true
      evpn_rt_imports = [
        "700:6200",
      ]
      evpn_rt_exports = [
        "700:6200",
      ]
      ext_l3_vlan = 62
      redistribute_ipv4 = {
        connected = {}
      }

      l2 = {
        2 = {
          vni                  = 9002
          vlan_id              = 2
          anycast_gw_ip        = "10.2.0.5"
          anycast_gw_cidr      = 16
          anycast_mac          = "0e:00:00:10:00:02"
          advertise_default_gw = false
          advertise_svi_ip     = false
          export_ipv4_unicast  = true
        }
        #5 = {
        #  vni                  = 9005
        #  vlan_id              = 5
        #  anycast_gw_ip        = "10.5.0.5"
        #  anycast_gw_cidr      = 16
        #  anycast_mac          = "0e:00:00:10:00:05"
        #  advertise_default_gw = false
        #  advertise_svi_ip     = false
        #  export_ipv4_unicast  = true
        #}
      }
    }
    6600 = {
      vni       = 6600
      vrf       = "lylat_service"
      vrf_table = 1000

      ipv4_rt_imports = "700:6200 700:6900"
      ipv4_rt_exports = "700:6600"

      BL_ipv4_rt_imports = "420:1337 420:666"
      BL_ipv4_rt_exports = "700:6600"

      export_vpn_ipv4 = true
      evpn_rt_imports = [
        "700:6600",
      ]
      evpn_rt_exports = [
        "700:6600",
      ]
      ext_l3_vlan = 66

      redistribute_ipv4 = {
        connected = {}
      }

      l2 = {
        6 = {
          vni                  = 9006
          vlan_id              = 6
          anycast_gw_ip        = "10.6.0.5"
          anycast_gw_cidr      = 16
          anycast_mac          = "0e:00:00:10:00:06"
          advertise_default_gw = false
          advertise_svi_ip     = false
          export_ipv4_unicast  = true
        }
        8 = {
          vni                  = 9008
          vlan_id              = 8
          anycast_gw_ip        = "10.8.0.5"
          anycast_gw_cidr      = 16
          anycast_mac          = "0e:00:00:10:00:08"
          advertise_default_gw = false
          advertise_svi_ip     = false
          export_ipv4_unicast  = true
        }
      }
    }
    6900 = {
      vni       = 6900
      vrf       = "lylat_lan"
      vrf_table = 1337

      ipv4_rt_imports = "700:6600"
      ipv4_rt_exports = "700:6900"

      BL_ipv4_rt_imports = "420:1337 420:666"
      BL_ipv4_rt_exports = "700:6900"

      export_vpn_ipv4 = true
      redistribute_ipv4 = {
        connected = {}
      }
      evpn_rt_imports = [
        "700:6900",
      ]
      evpn_rt_exports = [
        "700:6900",
      ]
      ext_l3_vlan = 69

      l2 = {
        9 = {
          vni                  = 9009
          vlan_id              = 9
          anycast_gw_ip        = "10.9.0.5"
          anycast_gw_cidr      = 16
          anycast_mac          = "0e:00:00:10:00:09"
          advertise_default_gw = false
          advertise_svi_ip     = false
          export_ipv4_unicast  = true
        }
      }
    }
  }
}
