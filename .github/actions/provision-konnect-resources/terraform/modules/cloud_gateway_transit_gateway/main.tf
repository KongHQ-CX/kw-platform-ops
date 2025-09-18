terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_cloud_gateway_transit_gateway" "this" {
  network_id = var.network_id

  aws_transit_gateway             = var.aws_transit_gateway
  aws_vpc_peering_gateway         = var.aws_vpc_peering_gateway
  azure_transit_gateway           = var.azure_transit_gateway
  gcp_vpc_peering_transit_gateway = var.gcp_vpc_peering_transit_gateway
}

output "id" {
  value = konnect_cloud_gateway_transit_gateway.this.id
}
