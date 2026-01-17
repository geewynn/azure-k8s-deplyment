variable "subscription_id" {
  description = "subscription id"
  type        = string
  sensitive   = false
}

variable "resource_group_name" {
  description = "resource_group_name"
  type = string
}

variable "resource_group_location" {
  description = "resource group location"
  type = string
}

variable "cluster_name" {
  description = "k8s cluster name"
  type = string
}

variable "dns_prefix" {
  description = "dns prefix"
  type = string
}


variable "node_pool_name" {
  description = "node pool name"
  type = string
}

variable "node_count" {
  description = "node pool count"
}

variable "vm_size" {
  description = "vm size"
  type = string
}

variable "db_host" {
  description = "db host"
  type = string
}

variable "db_port" {
  description = "db port"
  type = string
}


variable "db_user" {
  description = "db user"
  type = string
}

variable "db_password" {
  description = "db password"
  type = string
}

