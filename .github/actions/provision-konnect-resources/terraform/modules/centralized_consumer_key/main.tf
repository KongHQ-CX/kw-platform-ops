terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_centralized_consumer_key" "this" {
  realm_id    = var.realm_id
  consumer_id = var.consumer_id

  type   = var.key_type
  secret = var.secret
  tags   = length(var.tags) > 0 ? var.tags : null
}

