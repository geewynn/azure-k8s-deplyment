resource "azurerm_storage_account" "cnpg_backups" {
  name                     = var.cnpg_storage_account_name
  resource_group_name      = azurerm_resource_group.aks.name
  location                 = azurerm_resource_group.aks.location
  account_tier             = "Standard"
  account_replication_type = var.cnpg_storage_replication_type
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "cnpg" {
  for_each              = toset(var.cnpg_backup_containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.cnpg_backups.id
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "cnpg" {
  for_each          = toset(var.cnpg_backup_containers)
  connection_string = azurerm_storage_account.cnpg_backups.primary_connection_string
  container_name    = azurerm_storage_container.cnpg[each.key].name
  https_only        = true

  start  = timestamp()
  expiry = timeadd(timestamp(), "${var.cnpg_sas_expiry_hours}h")

  permissions {
    read   = true
    write  = true
    delete = true
    list   = true
    add    = true
    create = true
  }
}

resource "azurerm_key_vault_secret" "storage_account_name" {
  name         = "storage-account-name"
  value        = azurerm_storage_account.cnpg_backups.name
  key_vault_id = azurerm_key_vault.mercury_vault.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "cnpg_blob_sas" {
  for_each     = toset(var.cnpg_backup_containers)
  name         = "${each.value}-blob-sas"
  value        = data.azurerm_storage_account_blob_container_sas.cnpg[each.key].sas
  key_vault_id = azurerm_key_vault.mercury_vault.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

output "storage_account_name" {
  value = azurerm_storage_account.cnpg_backups.name
}

output "cnpg_backup_paths" {
  value = {
    for container in var.cnpg_backup_containers :
    container => "${azurerm_storage_account.cnpg_backups.primary_blob_endpoint}${container}"
  }
  description = "CNPG backup destination paths per customer"
}