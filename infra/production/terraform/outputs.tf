output "vm_metadata" {
    value = {
        for k, vm in proxmox_vm_qemu.vms :
        k => {
            ip   = regex("ip=([^,]+)", vm.ipconfig0)[0]
            name = vm.name
            tags = vm.tags
        }
    }
}