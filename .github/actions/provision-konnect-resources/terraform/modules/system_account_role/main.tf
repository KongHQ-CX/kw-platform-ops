terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_system_account_role" "this" {
  account_id       = var.account_id
  entity_type_name = var.entity_type_name
  role_name        = var.role_name
  entity_id        = var.entity_id
  entity_region    = var.entity_region
}
