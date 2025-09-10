terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_cloud_gateway_network" "this" {
  name                              = var.name
  region                            = var.region
  cidr_block                        = var.cidr_block
  availability_zones                = var.availability_zones
  cloud_gateway_provider_account_id = var.cloud_gateway_provider_account_id
}

output "id" {
  value = konnect_cloud_gateway_network.this.id
}
