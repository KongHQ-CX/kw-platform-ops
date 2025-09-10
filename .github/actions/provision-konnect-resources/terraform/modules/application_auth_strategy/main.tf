terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_application_auth_strategy" "this" {
  key_auth = var.strategy_type == "key_auth" ? {
    display_name  = var.display_name
    labels        = var.labels
    name          = var.name
    strategy_type = "key_auth"
    configs = {
      key_auth = {
        key_names = length(var.key_auth_key_names) > 0 ? var.key_auth_key_names : null
      }
    }
  } : null

  openid_connect = var.strategy_type == "openid_connect" ? {
    display_name    = var.display_name
    labels          = var.labels
    name            = var.name
    strategy_type   = "openid_connect"
    dcr_provider_id = var.oidc_dcr_provider_id
    configs = {
      openid_connect = {
        additional_properties = var.oidc_additional_properties
        auth_methods          = length(var.oidc_auth_methods) > 0 ? var.oidc_auth_methods : null
        credential_claim      = length(var.oidc_credential_claim) > 0 ? var.oidc_credential_claim : null
        issuer                = var.oidc_issuer
        scopes                = length(var.oidc_scopes) > 0 ? var.oidc_scopes : null
      }
    }
  } : null
}

