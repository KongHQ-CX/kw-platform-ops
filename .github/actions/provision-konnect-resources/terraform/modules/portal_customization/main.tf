terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_customization" "this" {
  portal_id = var.portal_id

  css    = var.css
  layout = var.layout
  robots = var.robots

  # Menu configuration - use argument syntax, not block syntax
  menu = var.menu

  # Spec renderer configuration - use argument syntax, not block syntax  
  spec_renderer = var.spec_renderer

  # Theme configuration - use argument syntax, not block syntax
  theme = var.theme
}