variable "name" {
  description = "The name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The name of the storage location"
  type        = string
}

variable "enable_https_traffic_only" {
  description = "forces HTTPS if enabled"
  type        = string
  default     = true
}
