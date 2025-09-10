variable "name" {
  description = "Name of the Cloud Gateway Network"
  type        = string
}

variable "region" {
  description = "Region where the network will be created (e.g., eu, us, apac)"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the network (e.g., 10.0.0.0/16)"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones in the region to use"
  type        = list(string)
}

variable "cloud_gateway_provider_account_id" {
  description = "The Cloud Gateway provider account ID"
  type        = string
}
