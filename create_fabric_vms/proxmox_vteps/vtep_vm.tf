resource "proxmox_virtual_environment_vm" "vyos_vxlan_vtep" {
  name            = var.host_node.hostname
  description     = "managed by opentofu"
  tags            = ["opentofu", "debian", "vyos", "vxlan"]
  started         = true
  keyboard_layout = "en-us"
  migrate         = false
  on_boot         = true
  reboot          = false
  stop_on_destroy = true


  node_name = var.host_node.hypervisor_node
  vm_id     = local.vm_id

  agent {
    enabled = true
  }

  boot_order = [
    "virtio0",
  ]

  disk {
    datastore_id = "ceph_rbd"
    import_from  = "cephfs:import/vyos-1.5-rolling-202607050926-qcow2-amd64.qcow2"
    #import_from  = "cephfs:import/vyos-1.5-rolling-202606080213-qcow2-amd64.qcow2"
    interface    = "virtio0"
    iothread     = true
    size         = 10
  }

  initialization {
    interface         = "scsi0"
    datastore_id      = "ceph_rbd"
    user_data_file_id = "cephfs:snippets/vyos_api.yml"
    ip_config {
      ipv4 {
        address = local.vxlan_mgmt_ip_sub
      }
    }
  }



  network_device {
    disconnected = false
    bridge       = "vmbr0"
    model        = "virtio"
  }

  dynamic "network_device" {
    for_each = local.underlay_bridges
    content {
      disconnected = false
      bridge       = network_device.value
      model        = "virtio"
      mtu          = 1
    }
  }


  serial_device {}

  cpu {
    #  architecture = "x86_64"
    cores      = 4
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 1
    type       = "x86-64-v2-AES"
    units      = 1024
  }

  memory {
    dedicated      = 4096
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }

  operating_system {
    type = "l26"
  }

  vga {
    #enabled = false
    memory = 16
    type   = "std"
  }
  timeout_clone       = 1800
  timeout_create      = 1800
  timeout_migrate     = 1800
  timeout_reboot      = 1800
  timeout_shutdown_vm = 1800
  timeout_start_vm    = 1800
  timeout_stop_vm     = 300


  lifecycle {
    ignore_changes = [
      #network_device[6].disconnected,
      initialization[0].user_account, # This ignores changes to the user_account block within initialization
      #vga[0].enabled,  # This ignores changes to the user_account block within initialization
    ]
  }
}
