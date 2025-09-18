terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_appearance" "this" {
  portal_id        = var.portal_id
  theme_name       = var.theme_name
  use_custom_fonts = var.use_custom_fonts
}
