variable "subscription_id" {
  type        = string
  description = "The subscription ID where the resources will be created."
}

variable "app_name" {
  type        = string
  default     = "sola-ro-integration"
  description = "Application subscription name"
}

variable "azure_wait_timer" {
  type        = string
  description = "(Optional) Wait timer for Azure dataplane propagation - Default: 360"
  default     = "360s"
}

variable "custom_role_name" {
  type        = string
  default     = "Sola Custom Role"
  description = "The name of the Azure custom role to create. Defaults to Sola Custom Role."
}