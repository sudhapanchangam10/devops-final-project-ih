variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "node_vm_size" {
  description = "Azure VM size for AKS worker nodes"
  type        = string
}

variable "node_count" {
  description = "Number of fixed AKS worker nodes"
  type        = number
}

variable "min_node_count" {
  description = "Minimum AKS node count"
  type        = number
}

variable "max_node_count" {
  description = "Maximum AKS node count"
  type        = number
}

variable "aks_authorized_ip_ranges" {
  description = "Public IP ranges allowed to access the AKS API server"
  type        = list(string)
}