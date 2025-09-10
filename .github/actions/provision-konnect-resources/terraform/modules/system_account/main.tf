terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_system_account" "this" {
  name            = var.name
  description     = coalesce(var.description, var.name)
  konnect_managed = var.konnect_managed
}
