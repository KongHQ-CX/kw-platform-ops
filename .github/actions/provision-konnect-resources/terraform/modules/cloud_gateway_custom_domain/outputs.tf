output "id" {
  description = "ID of the custom domain"
  value       = konnect_cloud_gateway_custom_domain.this.id
}

output "domain" {
  description = "Domain name"
  value       = konnect_cloud_gateway_custom_domain.this.domain
}
