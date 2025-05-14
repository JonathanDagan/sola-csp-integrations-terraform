output "credentials" {
  value = {
    "Tenant ID" : data.azuread_client_config.current.tenant_id,
    "Client ID" : azuread_application_registration.sola_app.client_id,
    "Client Secret" : azuread_application_password.sola_app_password.value,
  }
  sensitive = true
}
