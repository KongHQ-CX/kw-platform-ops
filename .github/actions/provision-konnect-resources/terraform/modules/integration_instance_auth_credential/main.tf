terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_integration_instance_auth_credential" "this" {
  integration_instance_id = var.integration_instance_id
  multi_key_auth          = var.multi_key_auth
}

output "id" {
  description = "Auth credential id"
  value       = konnect_integration_instance_auth_credential.this.id
}
