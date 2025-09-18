terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_api_implementation" "this" {

  api_id = var.api_id

  service = {
    control_plane_id = var.service.control_plane_id
    id               = var.service.id
  }
}
