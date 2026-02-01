# variables.tf

## Core Infrastructure
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Azure region for the resource group"
  type        = string
}

## AKS Cluster
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.32.0"
}

variable "aad_admin_group_ids" {
  description = "Azure AD group object IDs for cluster admin access"
  type        = list(string)
}

## System Node Pool
variable "node_pool_name" {
  description = "Name of the system node pool"
  type        = string
  default     = "systempool"
}

variable "node_count" {
  description = "Number of nodes in the system pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for the system node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

## User Node Pool
variable "user_pool_vm_size" {
  description = "VM size for the user node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "user_pool_node_count" {
  description = "Number of nodes in the user pool"
  type        = number
  default     = 2
}

## Key Vault
variable "kv_name" {
  description = "Name of the Key Vault"
  type        = string
}

## Flux GitOps
variable "flux_ext_name" {
  description = "Name of the Flux extension"
  type        = string
}

variable "flux_sys_name" {
  description = "Name of the Flux system namespace"
  type        = string
  default     = "flux-system"
}

variable "git_repository" {
  description = "Git repository URL for Flux"
  type        = string
}

## Secret Names (Key Vault keys)
variable "customer1_db_user_secret_name" {
  description = "Key Vault secret name for customer1 DB username"
  type        = string
  default     = "customer1-db-user"
}

variable "customer1_db_password_secret_name" {
  description = "Key Vault secret name for customer1 DB password"
  type        = string
  default     = "customer1-db-password"
}

variable "bot_token_secret_name" {
  description = "Key Vault secret name for bot token"
  type        = string
  default     = "bot-token"
}

variable "bot_chat_id_secret_name" {
  description = "Key Vault secret name for bot chat ID"
  type        = string
  default     = "bot-chat-id"
}

## Secret Values (sensitive)
variable "bot_token_value" {
  description = "Bot token value"
  type        = string
  sensitive   = true
}

variable "bot_chat_id_value" {
  description = "Bot chat ID value"
  type        = string
  sensitive   = true
}


## Flux GitOps

variable "flux_git_branch" {
  description = "Git branch to track"
  type        = string
  default     = "main"
}

variable "flux_repo_path" {
  description = "Base path in the git repository"
  type        = string
  default     = "n8n-gitops-deployment"
}

variable "flux_sync_interval" {
  description = "Sync interval in seconds for Flux kustomizations"
  type        = number
  default     = 300
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  default     = "staging"
}

variable "flux_ssh_private_key_path" {
  description = "Path to SSH private key for Flux"
  type        = string
}