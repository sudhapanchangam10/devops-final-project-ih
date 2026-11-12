
# =====================================================
# LOCAL VALUES
# Common resource naming convention and tags.
# =====================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # ACR names cannot contain hyphens.
  acr_name_prefix = replace(lower(var.project_name), "-", "")

  common_tags = {
    project     = "Expensy"
    environment = var.environment
    managed_by  = "Terraform"
  }
}

# =====================================================
# RESOURCE 1: RANDOM STRING
# Generates a unique suffix for the ACR name.
# =====================================================

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# =====================================================
# RESOURCE 2: AZURE RESOURCE GROUP
# Holds all Expensy development infrastructure.
# =====================================================

resource "azurerm_resource_group" "expensy" {
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = local.common_tags
}

# =====================================================
# RESOURCE 3: AZURE CONTAINER REGISTRY
# Stores frontend and backend Docker images.
# Basic SKU with registry admin access disabled.
# =====================================================

resource "azurerm_container_registry" "expensy" {
  name                = "${local.acr_name_prefix}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.expensy.name
  location            = azurerm_resource_group.expensy.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = local.common_tags
}

# =====================================================
# RESOURCE 4: AKS CONTROL PLANE MANAGED IDENTITY
# Provides an identity for AKS control-plane operations.
# =====================================================

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${local.name_prefix}-aks-identity"
  location            = azurerm_resource_group.expensy.location
  resource_group_name = azurerm_resource_group.expensy.name

  tags = local.common_tags
}

# =====================================================
# RESOURCE 5: KUBELET MANAGED IDENTITY
# Used by AKS worker nodes to authenticate with ACR.
# =====================================================

resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "${local.name_prefix}-kubelet-identity"
  location            = azurerm_resource_group.expensy.location
  resource_group_name = azurerm_resource_group.expensy.name

  tags = local.common_tags
}

# =====================================================
# RESOURCE 6: NETWORK CONTRIBUTOR PERMISSION
# Allows the AKS control-plane identity to manage
# the network resources associated with its subnet.
# =====================================================

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}

# =====================================================
# RESOURCE 7: MANAGED IDENTITY OPERATOR PERMISSION
# Allows AKS control-plane identity to use the
# separately created kubelet managed identity.
# =====================================================

resource "azurerm_role_assignment" "aks_kubelet_identity_operator" {
  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}

# =====================================================
# RESOURCE 8: ACR PULL PERMISSION
# Allows AKS worker nodes to pull private Docker images.
# =====================================================

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.expensy.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
  principal_type       = "ServicePrincipal"


}
