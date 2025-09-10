terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_api_document" "this" {

  # Required fields
  api_id  = var.api_id
  content = var.content

  # Optional fields
  # labels             = var.labels
  parent_document_id = var.parent_document_id
  slug               = var.slug
  status             = var.status
  title              = var.title
}
