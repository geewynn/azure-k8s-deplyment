resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = var.node_pool_name
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "cilium"
    network_data_plane = "cilium"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled=false
  }
}

## Key vault
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "n8n_vault" {
  name                = "kv-gee-n8n"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Make it easy to destroy and recreate
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Allow Terraform to manage secrets
  enable_rbac_authorization = true
  # azure_rbac_enabled = true 
  depends_on                 = [azurerm_kubernetes_cluster.main]
}

# Give yourself permission to manage secrets
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.n8n_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "aks_keyvault_secrets_provider" {
  scope                = azurerm_key_vault.n8n_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.main.key_vault_secrets_provider[0].secret_identity[0].object_id
}

# Create the secrets
resource "azurerm_key_vault_secret" "db_host" {
  name         = "db-host"
  value        = var.db_host
  key_vault_id = azurerm_key_vault.n8n_vault.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "db_port" {
  name         = "db-port"
  value        = var.db_port
  key_vault_id = azurerm_key_vault.n8n_vault.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = var.db_user
  key_vault_id = azurerm_key_vault.n8n_vault.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.n8n_vault.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

