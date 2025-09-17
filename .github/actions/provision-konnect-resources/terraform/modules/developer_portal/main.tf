terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal" "this" {
  name                                 = var.name
  description                          = var.description
  display_name                         = var.display_name
  labels                               = var.labels
  authentication_enabled               = var.authentication_enabled
  auto_approve_applications            = var.auto_approve_applications
  auto_approve_developers              = var.auto_approve_developers
  default_api_visibility               = var.default_api_visibility
  default_application_auth_strategy_id = var.default_application_auth_strategy_id
  default_page_visibility              = var.default_page_visibility
  rbac_enabled                         = var.rbac_enabled
  force_destroy                        = var.force_destroy
}
