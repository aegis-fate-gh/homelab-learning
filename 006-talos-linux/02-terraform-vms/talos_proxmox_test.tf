terraform {
  required_providers {
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.20" # Use the latest available version
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.121.0"
    }
  }
}

data "infisical_secrets" "proxmox_secrets" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/proxmox"
}

resource "proxmox_virtual_environment_vm" "talos_vms" {
    for_each = { for c in var.clients : c.name => c }
    name = each.value.name
    vm_id = each.value.vm_id
    description = "Managed by OpenTofu"

    node_name = "pve-andromeda"

    boot_order = ["virtio0", "ide2"]

    agent {
        enabled = true
    }

    bios = "ovmf"
    machine = "q35"
    
    cpu {
        cores = each.value.cores
        type = "host"
    }
    memory {
        dedicated = each.value.memory
    }
    cdrom {
        file_id = "local:iso/talos-nocloud-amd64.iso"
        interface = "ide2"
    }
    disk {
        datastore_id = "nvme-pool"
        interface = "virtio0"
        cache = "writethrough"
        size = 20
        file_format = "raw" #ZFS only supports raw
        iothread = true
        discard = "on"
    }

    efi_disk {
        datastore_id = "nvme-pool"
        type = "4m"
        pre_enrolled_keys = false
    }
    network_device {
        bridge = "vmbr0"
        mac_address = each.value.mac
        model = "virtio"
        vlan_id = "7"
    }
    network_device {
        bridge = "vmbr1"
        model = "virtio"
        vlan_id = "100"
    }
    operating_system {
        type = "l26"
    }

}
