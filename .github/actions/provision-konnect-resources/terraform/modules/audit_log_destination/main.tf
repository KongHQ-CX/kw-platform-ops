terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_audit_log_destination" "this" {
  name                  = var.name
  endpoint              = var.endpoint
  authorization         = var.authorization
  log_format            = var.log_format
  skip_ssl_verification = var.skip_ssl_verification
}

output "id" {
  description = "The audit log destination ID"
  value       = konnect_audit_log_destination.this.id
}

output "name" {
  description = "The audit log destination name"
  value       = konnect_audit_log_destination.this.name
}
