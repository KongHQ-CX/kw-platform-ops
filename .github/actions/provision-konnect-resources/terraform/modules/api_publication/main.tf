terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_api_publication" "this" {

  api_id    = var.api_id
  portal_id = var.portal_id

  auth_strategy_ids          = var.auth_strategy_ids
  auto_approve_registrations = var.auto_approve_registrations
  visibility                 = var.visibility
}
