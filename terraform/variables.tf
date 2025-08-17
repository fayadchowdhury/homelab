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

variable "PM_SERVER_URL" {
    type = string
    description = "API URL for Proxmox provider"
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
        storage_location = string
        storage_size = string
        ipv4 = string
        gw = string
    }))
    description = "The list of VM definitions to base deployment off of"
}