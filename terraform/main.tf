terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}

provider "proxmox" {
  pm_api_url            = var.PM_SERVER_URL
  pm_api_token_id       = var.PM_API_TOKEN_ID
  pm_api_token_secret   = var.PM_API_TOKEN_SECRET
  pm_debug              = true
  pm_log_enable         = true
  pm_log_file           = "terraform-plugin-proxmox.log"
  pm_tls_insecure       = true
}

resource "proxmox_vm_qemu" "vms" {
  for_each          = {
    for index, vm in var.VM_DEFINITIONS: vm.name => vm
  }
  name              = each.value.name # Name of VM
  target_node       = each.value.target_node # Node to place the VM on
  vmid              = each.value.vmid # VM ID

  clone             = each.value.template # Name of prebuilt cloud-init template
  full_clone        = true # Full clone instead of linked clone
  onboot            = true # Whether to start on boot or not
  vm_state          = "running" # Desired VM state
  agent             = 1 # To enable QEMU guest agent
  
  cpu { # CPU config
    cores           = each.value.cpu_cores # Number of cores to assign
    sockets         = each.value.cpu_sockets # Number of sockets to assign
  }

  memory            = each.value.memory # Size in MB of memory to assign
  
  disks {
    scsi {
      scsi0 {
        # SCSI disk from installation
        disk {
          storage   = each.value.storage_location # Location of disk
          size      = each.value.storage_size # Size of disk
        }
      }
    }
    ide {
      # IDE (CD-ROM) for cloud-init disk
      ide1 {
        cloudinit {
          storage   = "ceph-storage"
        }
      }
    }
  }

  serial {
    id              = 0 # The ID of the serial port (usually 0 for the first one)
    type            = "socket" # Specifies that the serial port type is a socket
  }

  # For Proxmox UI console to use this serial port
  vga {
    type            = "serial0" # Directs the VGA output to serial port 0
  }

  scsihw            = "virtio-scsi-pci" # Needs to be set to something like virtio-scsi-pci or virtio-scsi-single
  network { # Network config
    id              = 0 # Required argument
    bridge          = "vmbr0" # Default bridged network
    model           = "virtio" # Type of network
  }

  os_type           = "cloud-init" # Required for cloud-init template based VMs
  ipconfig0         = "ip=${each.value.ipv4},gw=${each.value.gw}" # IPv4 config

  ciuser            = var.CI_USER # cloud-init user; not setting this sometimes leaves empty cloud-user and password (even though it is already defined in the cloud-init template)
  cipassword        = var.CI_PASSWORD # cloud-init user password

  # SSH keys to log in to VM
  sshkeys           = file(var.SSH_KEYS_FILE)

}