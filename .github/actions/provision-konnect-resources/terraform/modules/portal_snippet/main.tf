terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_portal_snippet" "this" {
  portal_id   = var.portal_id
  name        = var.name
  content     = var.content
  title       = var.title
  description = var.description
  status      = var.status
  visibility  = var.visibility
}
