terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_integration_instance" "this" {
  name             = var.name
  display_name     = var.display_name
  integration_name = var.integration_name
  description      = var.description
  config           = var.config
}

output "id" {
  description = "The integration instance ID"
  value       = konnect_integration_instance.this.id
}

output "name" {
  description = "The integration instance name"
  value       = konnect_integration_instance.this.name
}
