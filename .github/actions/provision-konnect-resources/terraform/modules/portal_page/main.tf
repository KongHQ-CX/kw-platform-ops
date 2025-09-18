terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_page" "this" {
  portal_id      = var.portal_id
  slug           = var.slug
  content        = var.content
  title          = var.title
  description    = var.description
  parent_page_id = var.parent_page_id
  status         = var.status
  visibility     = var.visibility
}
