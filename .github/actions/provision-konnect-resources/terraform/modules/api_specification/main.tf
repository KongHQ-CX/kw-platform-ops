terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_api_specification" "this" {
  api_id  = var.api_id
  content = var.content
  type    = var.type
}
