# IMPORTANT: Register provider first: az provider register --namespace Microsoft.KubernetesConfiguration

resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = var.flux_ext_name
  cluster_id     = azurerm_kubernetes_cluster.main.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "main" {
  name       = var.flux_sys_name
  cluster_id = azurerm_kubernetes_cluster.main.id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                    = var.git_repository
    reference_type         = "branch"
    reference_value        = var.flux_git_branch
    # ssh_private_key_base64 = base64encode(var.flux_ssh_private_key)
    ssh_private_key_base64 = base64encode(file(pathexpand(var.flux_ssh_private_key_path)))

  }

  kustomizations {
    name                       = "infra-controllers"
    path                       = "./${var.flux_repo_path}/infrastructure/controllers/${var.environment}"
    sync_interval_in_seconds   = var.flux_sync_interval
    garbage_collection_enabled = true
  }

  kustomizations {
    name                       = "infra-configs"
    path                       = "./${var.flux_repo_path}/infrastructure/configs/${var.environment}"
    sync_interval_in_seconds   = var.flux_sync_interval
    depends_on                 = ["infra-controllers"]
    garbage_collection_enabled = true
  }

  kustomizations {
    name                       = "monitoring-controllers"
    path                       = "./${var.flux_repo_path}/monitoring/controllers/${var.environment}"
    sync_interval_in_seconds   = var.flux_sync_interval
    depends_on                 = ["infra-controllers"]
    garbage_collection_enabled = true
  }

  kustomizations {
    name                       = "monitoring-configs"
    path                       = "./${var.flux_repo_path}/monitoring/configs/${var.environment}"
    sync_interval_in_seconds   = var.flux_sync_interval
    depends_on                 = ["monitoring-controllers"]
    garbage_collection_enabled = true
  }

  kustomizations {
    name                       = "apps"
    path                       = "./${var.flux_repo_path}/apps/${var.environment}"
    sync_interval_in_seconds   = var.flux_sync_interval
    depends_on                 = ["infra-configs"]
    garbage_collection_enabled = true
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
}