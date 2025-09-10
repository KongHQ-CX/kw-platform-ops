terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_cloud_gateway_configuration" "this" {
  control_plane_id  = var.control_plane_id
  control_plane_geo = var.control_plane_geo
  dataplane_groups  = var.dataplane_groups
  version           = var.config_version
}

output "id" {
  value = konnect_cloud_gateway_configuration.this.id
}
