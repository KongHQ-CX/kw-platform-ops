terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_product_version" "this" {
  portal_id                        = var.portal_id
  product_version_id               = var.product_version_id
  publish_status                   = var.publish_status
  application_registration_enabled = var.application_registration_enabled
  auto_approve_registration        = var.auto_approve_registration
  deprecated                       = var.deprecated
  auth_strategy_ids                = var.auth_strategy_ids
  notify_developers                = var.notify_developers
}
