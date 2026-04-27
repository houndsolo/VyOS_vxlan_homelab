fabric = {
  spines = {
    rtr1 = {
      id = 1
    }
    rtr2 = {
      id = 2
    }
  }
  leaves = {
    fichina = {
      hypervisor_node = "fichina"
      id = 10
    }
    fortuna = {
      hypervisor_node = "fortuna"
      id = 11
    }
    macbeth = {
      hypervisor_node = "macbeth"
      id = 12
    }
    titania = {
      hypervisor_node = "titania"
      id = 13
    }
    zoness = {
      hypervisor_node = "zoness"
      id = 14
    }
    venom = {
      hypervisor_node = "venom"
      id = 17
    }
    eldarad = {
      hypervisor_node = "eldarad"
      id = 21
    }
  }
  border_leaves = {
    border18  = {
      hypervisor_node = "fichina"
      id = 18
    }
    border19  = {
      hypervisor_node = "eldarad"
      id = 19
    }
  }
  leaves_greatfox = {
    greatfox = {
      hypervisor_node = "greatfox"
      id = 20
    }
  }
}

dns = {
  name_servers = ["10.8.6.9"]
  domain_name = "lylat.space"
  domain_search = ["lylat.space"]
}

vnis = {
  l2 ={
    6 = {
      type        = "L2"
      vni         = 9006
      vlan_id     = 6
      vrf         = "lylat_service"
      anycast_gw_ip  = "10.6.0.5"
      anycast_gw_cidr  = 16
      anycast_mac = "0e:00:00:10:00:06"
      advertise_default_gw = false
      advertise_svi_ip = false
    }
    8 = {
      type        = "L2"
      vni         = 9008
      vlan_id     = 8
      vrf         = "lylat_lan"
      anycast_gw_ip  = "10.8.0.5"
      anycast_gw_cidr  = 16
      anycast_mac = "0e:00:00:10:00:08"
      advertise_default_gw = true
      advertise_svi_ip = true
    }
    9 = {
      type        = "L2"
      vni         = 9009
      vlan_id     = 9
      vrf         = "lylat_lan"
      anycast_gw_ip  = "10.9.0.5"
      anycast_gw_cidr  = 16
      anycast_mac = "0e:00:00:10:00:09"
      advertise_default_gw = true
      advertise_svi_ip = true
    }
  }
  l3 = {
    6600 = {
      type        = "L3"
      vni         = 6600
      vrf         = "lylat_service"
      vrf_table   = 1000
      rt_imports  = null
      rt_exports  = "700:6600"
    }
    6900 = {
      type        = "L3"
      vni         = 6900
      vrf         = "lylat_lan"
      vrf_table   = 1337
      rt_imports  = "420:1337"
      rt_exports  = "700:6900"
    }
  }
}
