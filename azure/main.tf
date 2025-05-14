locals {
  custom_role_name = var.custom_role_name
  custom_role_permissions = [
    "*/read",
    "Microsoft.Authorization/*/read",
    "Microsoft.Insights/alertRules/read",
    "Microsoft.operationalInsights/workspaces/*/read",
    "Microsoft.Resources/deployments/*/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Security/*/read",
    "Microsoft.IoTSecurity/*/read",
    "Microsoft.Support/*/read",
    "Microsoft.Security/iotDefenderSettings/packageDownloads/action",
    "Microsoft.Security/iotDefenderSettings/downloadManagerActivation/action",
    "Microsoft.Security/iotSensors/downloadResetPassword/action",
    "Microsoft.IoTSecurity/defenderSettings/packageDownloads/action",
    "Microsoft.IoTSecurity/defenderSettings/downloadManagerActivation/action",
    "Microsoft.Management/managementGroups/read",
    "Microsoft.ContainerRegistry/registries/listCredentials/action"
  ]
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

resource "azurerm_role_definition" "sola_custom_role" {
  name        = local.custom_role_name
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom Sola role for ${var.app_name}"
  permissions {
    actions = local.custom_role_permissions
  }
  assignable_scopes = ["/subscriptions/${var.subscription_id}"]
}

resource "azurerm_role_assignment" "sola_custom_role_assignment" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = azurerm_role_definition.sola_custom_role.name
  principal_id         = azuread_service_principal.sola_sp.object_id
}

# Create the Sola custom roles with a time delay to allow the Azure dataplane to catch up. You can leave the max default variable to the default.
# The creation of Azure custom role can take several minutes and needs to be completed before the role assignments are made, or the role assignments will simply not happen.
# Similarly, you may notice that deletion of the custom role can take several minutes to complete when you run `terraform destroy`.
resource "time_sleep" "wait_for_az_dataplane_custom_role" {
  create_duration = var.azure_wait_timer
  depends_on      = [azurerm_role_definition.sola_custom_role]
}
