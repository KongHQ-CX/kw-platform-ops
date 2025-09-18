terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_api" "this" {

  # Required fields
  name = var.name

  # Optional fields
  description  = var.description
  labels       = var.labels
  slug         = var.slug
  spec_content = var.spec_content
  version      = var.api_version
}

resource "konnect_api_publication" "this" {

  for_each = { for portal in var.portals : portal.id => portal }

  api_id = konnect_api.this.id

  portal_id  = each.value.id
  visibility = lookup(each.value, "visibility", "private")
}
