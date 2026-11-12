
# =====================================================
# TERRAFORM OUTPUT VALUES
# Displays important infrastructure details after apply.
# =====================================================

# Azure Resource Group
output "resource_group_name" {
  description = "Expensy development resource group."
  value       = azurerm_resource_group.expensy.name
}

# Azure deployment region
output "location" {
  description = "Azure deployment region."
  value       = azurerm_resource_group.expensy.location
}

# Azure Virtual Network
output "virtual_network_name" {
  description = "Expensy virtual network name."
  value       = azurerm_virtual_network.expensy.name
}

output "virtual_network_address_space" {
  description = "Virtual network address space."
  value       = azurerm_virtual_network.expensy.address_space
}

# AKS subnet
output "aks_subnet_name" {
  description = "AKS subnet name."
  value       = azurerm_subnet.aks.name
}

output "aks_subnet_id" {
  description = "AKS subnet resource ID."
  value       = azurerm_subnet.aks.id
}

# Network Security Group
output "network_security_group_name" {
  description = "AKS network security group."
  value       = azurerm_network_security_group.aks.name
}

# Azure Container Registry
output "acr_name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.expensy.name
}

output "acr_login_server" {
  description = "ACR login server."
  value       = azurerm_container_registry.expensy.login_server
}

# AKS Cluster
output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.expensy.name
}

output "aks_cluster_location" {
  description = "AKS cluster location."
  value       = azurerm_kubernetes_cluster.expensy.location
}

# AKS Node Pool
output "aks_node_vm_size" {
  description = "AKS worker node VM size."
  value       = var.node_vm_size
}

output "aks_initial_node_count" {
  description = "Initial AKS node count."
  value       = var.node_count
}

# AKS managed resource group
output "aks_node_resource_group" {
  description = "Azure-managed resource group for AKS nodes."
  value       = azurerm_kubernetes_cluster.expensy.node_resource_group
}

# AKS credentials command
output "get_aks_credentials_command" {
  description = "Command to configure kubectl."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.expensy.name} --name ${azurerm_kubernetes_cluster.expensy.name}"
}
