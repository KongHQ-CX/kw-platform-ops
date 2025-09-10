variable "network_id" {
  description = "The Cloud Gateway network ID"
  type        = string
}

variable "name" {
  description = "Optional name of the Private DNS"
  type        = string
  default     = null
}

variable "private_dns_attachment_config" {
  description = "Attachment config object. Example: { aws_private_dns_resolver_attachment_config = { kind = \"aws-outbound-resolver\", dns_config = { remote_dns_server_ip_addresses = [..] } } } or { aws_private_hosted_zone_attachment_config = { kind = \"aws-private-hosted-zone-attachment\", hosted_zone_id = \"...\" } }"
  type        = any
  default     = null
}
