resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.aad_admin_group_ids
  }

  # Automatic upgrades,  patch level only for stability
  automatic_upgrade_channel = "patch"

  # Node OS auto-upgrade for security patches
  node_os_upgrade_channel = "NodeImage"

  default_node_pool {
    name       = var.node_pool_name
    node_count = var.node_count
    vm_size    = var.vm_size
    only_critical_addons_enabled = true # Adds CriticalAddonsOnly taint

    upgrade_settings {
      max_surge = "33%" # Microsoft recommended for production
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "cilium"
    network_data_plane = "cilium"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  # Maintenance windows - schedule upgrades during low-traffic periods
  # Microsoft recommends at least 4 hours duration
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+00:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+00:00"
  }
}

# User node pool - for application workloads
# No taint, so pods schedule here by default
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_pool_vm_size  #"Standard_D2s_v3"
  node_count            = var.user_pool_node_count

  upgrade_settings {
    max_surge = "33%"
  }
}

