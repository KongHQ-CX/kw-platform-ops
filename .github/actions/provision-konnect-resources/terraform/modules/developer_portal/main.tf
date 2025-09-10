terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal" "this" {
  name        = var.name
  description = var.description
  labels      = var.labels
}

output "id" {
  value       = konnect_portal.this.id
  description = "Portal ID"
}

output "name" {
  value       = konnect_portal.this.name
  description = "Portal name"
}
