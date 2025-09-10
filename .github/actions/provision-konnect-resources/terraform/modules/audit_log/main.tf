terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_audit_log" "this" {
  endpoint              = var.endpoint
  authorization         = var.authorization
  enabled               = var.enabled
  log_format            = var.log_format
  skip_ssl_verification = var.skip_ssl_verification
}

