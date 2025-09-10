variable "network_id" {
  description = "Cloud Gateway Network ID"
  type        = string
}

# One of aws_transit_gateway, aws_vpc_peering_gateway, azure_transit_gateway, gcp_vpc_peering_transit_gateway
variable "aws_transit_gateway" {
  description = "AWS Transit Gateway block"
  type        = any
  default     = null
}

variable "aws_vpc_peering_gateway" {
  description = "AWS VPC peering attachment block"
  type        = any
  default     = null
}

variable "azure_transit_gateway" {
  description = "Azure VNET peering attachment block"
  type        = any
  default     = null
}

variable "gcp_vpc_peering_transit_gateway" {
  description = "GCP VPC peering attachment block"
  type        = any
  default     = null
}
