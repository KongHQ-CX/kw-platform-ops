terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_favicon" "this" {
  portal_id = var.portal_id
  data      = var.data
}
