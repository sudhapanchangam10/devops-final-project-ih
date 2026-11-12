# =====================================================
# AZURE VIRTUAL NETWORK
# Creates the private network for the Expensy project.
# =====================================================

resource "azurerm_virtual_network" "expensy" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.expensy.location
  resource_group_name = azurerm_resource_group.expensy.name

  address_space = ["10.0.0.0/16"]

  tags = local.common_tags
}

# =====================================================
# AKS SUBNET
# Dedicated subnet for AKS worker node infrastructure.
# =====================================================

resource "azurerm_subnet" "aks" {
  name                 = "${local.name_prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.expensy.name
  virtual_network_name = azurerm_virtual_network.expensy.name

  address_prefixes = ["10.0.1.0/24"]
}

# =====================================================
# NETWORK SECURITY GROUP
# Controls network traffic associated with the AKS subnet.
# Azure's default NSG rules allow VNet and Azure Load
# Balancer traffic and deny other unsolicited inbound traffic.
# =====================================================

resource "azurerm_network_security_group" "aks" {
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.expensy.location
  resource_group_name = azurerm_resource_group.expensy.name

  tags = local.common_tags
}

# =====================================================
# SUBNET AND NSG ASSOCIATION
# Attaches the NSG to the AKS subnet.
# =====================================================

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}
# =====================================================
# INBOUND: ALLOW EXPENSY FRONTEND NODEPORT
# Azure Load Balancer frontend port 80
# forwards traffic to AKS NodePort 32469.
# =====================================================

resource "azurerm_network_security_rule" "allow_frontend_nodeport" {
  name                        = "Allow-Expensy-Frontend-NodePort"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  source_address_prefix       = "Internet"

  destination_port_range      = "80"
  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.expensy.name
  network_security_group_name = azurerm_network_security_group.aks.name
}