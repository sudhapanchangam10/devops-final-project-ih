

resource "azurerm_kubernetes_cluster" "expensy" {
  name                = "${local.name_prefix}-aks"
  location            = azurerm_resource_group.expensy.location
  resource_group_name = azurerm_resource_group.expensy.name
  dns_prefix          = "${local.name_prefix}-${random_string.suffix.result}"

  sku_tier = "Free"

  # Restrict API access to your current public IP.
  api_server_access_profile {
    authorized_ip_ranges = var.aks_authorized_ip_ranges
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  # Two fixed system worker nodes.
  default_node_pool {
    name                        = "system"
    vm_size                     = var.node_vm_size
    node_count                  = var.node_count
    auto_scaling_enabled        = false
    type                        = "VirtualMachineScaleSets"
    os_disk_size_gb             = 64
    vnet_subnet_id              = azurerm_subnet.aks.id
    temporary_name_for_rotation = "sysrotate"
  }

  # Azure CNI Overlay with Cilium.
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"

    load_balancer_sku = "standard"

    service_cidr   = "10.200.0.0/16"
    dns_service_ip = "10.200.0.10"
    pod_cidr       = "10.244.0.0/16"
  }

  tags = local.common_tags

  depends_on = [
    azurerm_role_assignment.aks_network_contributor,
    azurerm_role_assignment.aks_kubelet_identity_operator,
    azurerm_subnet_network_security_group_association.aks
  ]
}
