variable "subscription_id" {
  type        = string
  description = "The subscription ID where the resources will be created."
}

variable "app_name" {
  type        = string
  default     = "sola-ro-integration"
  description = "Application subscription name"
}

variable "custom_role_name" {
  type        = string
  default     = "Sola Custom Role"
  description = "The name of the Azure custom role to create. Defaults to Sola Custom Role."
}
