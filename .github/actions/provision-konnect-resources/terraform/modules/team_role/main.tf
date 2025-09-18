terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_team_role" "this" {
  team_id          = var.team_id
  entity_type_name = var.entity_type_name
  role_name        = var.role_name
  entity_id        = var.entity_id
  entity_region    = var.entity_region
}
