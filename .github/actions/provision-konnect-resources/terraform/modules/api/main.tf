terraform {
  required_providers {
    konnect-beta = {
      source = "kong/konnect-beta"
    }
  }
}

resource "konnect_api" "this" {
  provider = konnect-beta

  # Required fields
  name = var.name

  # Optional fields
  # deprecated   = var.deprecated
  description  = var.description
  labels       = var.labels
  slug         = var.slug
  spec_content = var.spec_content
  version      = var.api_version
}

resource "konnect_api_publication" "this" {

  for_each = { for portal in var.portals : portal.name => portal }

  provider = konnect-beta
  api_id = konnect_api.this.id
  
  portal_id                  = "4e0c036d-5bac-43e5-a85a-0d88203ecce1" # Hardcoded for now
  visibility                 = lookup(each.value, "visibility", "private")
}
