terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_auth" "this" {
  portal_id = var.portal_id

  # Enablement flags
  basic_auth_enabled        = var.basic_auth_enabled
  oidc_auth_enabled         = var.oidc_auth_enabled
  saml_auth_enabled         = var.saml_auth_enabled
  idp_mapping_enabled       = var.idp_mapping_enabled
  konnect_mapping_enabled   = var.konnect_mapping_enabled
  oidc_team_mapping_enabled = var.oidc_team_mapping_enabled

  # OIDC configuration
  oidc_issuer        = var.oidc_issuer
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = var.oidc_client_secret
  oidc_scopes        = length(var.oidc_scopes) > 0 ? var.oidc_scopes : null
}

output "portal_id" {
  value       = konnect_portal_auth.this.portal_id
  description = "Portal ID for which auth is configured"
}
