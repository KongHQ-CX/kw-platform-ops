terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_realm" "this" {
  name                     = var.name
  allow_all_control_planes = var.allow_all_control_planes
  allowed_control_planes   = length(var.allowed_control_planes) > 0 ? var.allowed_control_planes : null
  consumer_groups          = length(var.consumer_groups) > 0 ? var.consumer_groups : null
  ttl                      = var.ttl
  negative_ttl             = var.negative_ttl
  force_destroy            = var.force_destroy
}

