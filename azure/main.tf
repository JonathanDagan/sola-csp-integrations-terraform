locals {
  roles = ["Reader", "Security Reader"]
}

data "azuread_client_config" "current" {}

resource "random_string" "sola_app_postfix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "azuread_application_registration" "sola_app" {
  display_name = "${var.app_name}-${random_string.sola_app_postfix.result}"
}

resource "azuread_service_principal" "sola_sp" {
  client_id   = azuread_application_registration.sola_app.client_id
  description = "Sola's integration application service principal"
}

resource "azuread_application_password" "sola_app_password" {
  application_id = azuread_application_registration.sola_app.id
  end_date       = timeadd(timestamp(), "87600h") # 10 years
}

resource "azurerm_role_assignment" "sola_sp_roles" {
  for_each             = toset(local.roles)
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = each.value
  principal_id         = azuread_service_principal.sola_sp.object_id
}
