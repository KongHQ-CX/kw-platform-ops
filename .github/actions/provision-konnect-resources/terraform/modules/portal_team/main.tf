terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_team" "this" {
  portal_id = var.portal_id
  name      = var.name
}

output "id" {
  value       = konnect_portal_team.this.id
  description = "Portal team membership id"
}
