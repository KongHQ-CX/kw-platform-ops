terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_team" "this" {
  name        = var.name
  description = var.description
  labels      = var.labels
}
