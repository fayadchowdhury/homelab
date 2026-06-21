variable "PM_API_TOKEN_ID" {
    type = string
    description = "Token ID for API token used for Proxmox provider"
    sensitive = true
}

variable "PM_API_TOKEN_SECRET" {
    type = string
    description = "Token secret for API token used for Proxmox provider"
    sensitive = true
}

variable "PM_HOST" {
    type = string
    description = "Node hostname for Proxmox"
}

variable "PM_DOMAIN" {
    type = string
    description = "Domain suffix for all Proxmox hosts"
}

variable "SSH_KEYS_FILE" {
    type = string
    description = "The location of the SSH keys to assign to the VM for secured access"
    sensitive = true
}

variable "CI_USER" {
    type = string
    description = "The cloud init user name to use for the VM"
    sensitive = true
}

variable "CI_PASSWORD" {
    type = string
    description = "The cloud init user password to use for the VM"
    sensitive = true
}

variable "VM_DEFINITIONS" {
    type = list(object({
        name = string
        target_node = string
        vmid = number
        template = string
        cpu_cores = number
        cpu_sockets = number
        memory = number
        intermediate_storage_location = string
        final_storage_location = string
        final_storage_size = string
        extra_disk = optional(object({
            storage = string
            size    = string
        }))
        ipv4 = string
        gw = string
        cloudinit_disk_storage = string
        tags = string
    }))
    description = "The list of VM definitions to base deployment off of"
}