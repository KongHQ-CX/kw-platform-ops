terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_integration_instance_auth_config" "this" {
  integration_instance_id = var.integration_instance_id
  oauth_config            = var.oauth_config
}

output "integration_instance_id" {
  description = "Integration instance id"
  value       = konnect_integration_instance_auth_config.this.integration_instance_id
}
