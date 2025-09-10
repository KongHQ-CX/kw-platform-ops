terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_centralized_consumer" "this" {
  realm_id = var.realm_id
  username = var.username

  custom_id       = var.custom_id
  type            = var.consumer_type
  consumer_groups = length(var.consumer_groups) > 0 ? var.consumer_groups : null
  tags            = length(var.tags) > 0 ? var.tags : null
}

