terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_api_version" "this" {
  api_id = var.api_id

  spec = {
    content = var.spec_content
  }

  version = var.api_version
}
