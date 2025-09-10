terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_cloud_gateway_custom_domain" "this" {
  control_plane_id  = var.control_plane_id
  control_plane_geo = var.control_plane_geo
  domain            = var.domain
}
