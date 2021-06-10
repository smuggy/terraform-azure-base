variable rg_name {
  description = "resource group name for VM"
}

variable rg_location {
  description = "resource group location for the VM"
}

variable environment {
  description = "environment type"
  default     = "sandbox"
}

variable zone {
  description = "zone where the instance will be placed"
  type        = string
}

variable subnet {
  description = "subnet id where the instance will be placed"
  type        = string
}

variable app {
  description = "application associated with server"
}

variable volume_size {
  default = []
  type    = list(number)
}

variable server_group {
  description = "server group"
  default     = 1
  type        = number
}

variable server_number {
  description = "server number"
  default     = 1
  type        = number
}

variable ssh_public_key {
  description = "Public key for access to the VM"
}

variable instance_size {
  description = "Azure instance size for the VMs"
  default     = "Standard_B1s"
}

variable server_type {
  description = "Server type"
  default     = "srv"
}

//variable export_stats {
//  description = "Export statistics"
//  type        = bool
//  default     = true
//}

variable ami_id {
  description = "AMI ID of the OS"
  default     = ""
}

variable dns_rg_name {
  description = "dns resource group name"
}

variable identity {
  description = "service principal attached to the vm instances"
  type        = list(object({id_type= string, id = string}))
  default     = []
}
