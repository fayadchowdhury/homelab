output "vm_metadata" {
    value = {
        for k, vm in proxmox_vm_qemu.vms :
        k => {
            ip0  = regex("ip=([^,]+)", vm.ipconfig0)[0]
            ip1  = regex("ip=([^,]+)", vm.ipconfig1)[0]
            name = vm.name
            tags = vm.tags
        }
    }
}