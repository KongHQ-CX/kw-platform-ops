terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

locals {
  days_to_hours  = 365 * 24 // 1 year
  default_expiry = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

resource "konnect_system_account_access_token" "this" {
  account_id = var.account_id
  name       = var.name
  expires_at = coalesce(var.expires_at, local.default_expiry)
}

output "id" {
  value       = konnect_system_account_access_token.this.id
  description = "System account access token ID"
}

output "token" {
  value       = konnect_system_account_access_token.this.token
  description = "The generated token"
  sensitive   = true
}
