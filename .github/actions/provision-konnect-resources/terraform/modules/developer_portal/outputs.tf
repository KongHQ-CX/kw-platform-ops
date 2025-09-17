output "id" {
  value       = konnect_portal.this.id
  description = "Portal ID"
}

output "name" {
  value       = konnect_portal.this.name
  description = "Portal name"
}

output "display_name" {
  value       = konnect_portal.this.display_name
  description = "Portal display name"
}

output "description" {
  value       = konnect_portal.this.description
  description = "Portal description"
}

output "labels" {
  value       = konnect_portal.this.labels
  description = "Portal labels"
}

output "canonical_domain" {
  value       = konnect_portal.this.canonical_domain
  description = "The canonical domain of the developer portal"
}

output "default_domain" {
  value       = konnect_portal.this.default_domain
  description = "The domain assigned to the portal by Konnect. This is the default place to access the portal and its API if not using a custom_domain."
}

output "authentication_enabled" {
  value       = konnect_portal.this.authentication_enabled
  description = "Whether the portal supports developer authentication"
}

output "auto_approve_applications" {
  value       = konnect_portal.this.auto_approve_applications
  description = "Whether requests from applications to register for APIs will be automatically approved"
}

output "auto_approve_developers" {
  value       = konnect_portal.this.auto_approve_developers
  description = "Whether developer account registrations will be automatically approved"
}

output "default_api_visibility" {
  value       = konnect_portal.this.default_api_visibility
  description = "The default visibility of APIs in the portal"
}

output "default_application_auth_strategy_id" {
  value       = konnect_portal.this.default_application_auth_strategy_id
  description = "The default authentication strategy for APIs published to the portal"
}

output "default_page_visibility" {
  value       = konnect_portal.this.default_page_visibility
  description = "The default visibility of pages in the portal"
}

output "rbac_enabled" {
  value       = konnect_portal.this.rbac_enabled
  description = "Whether the portal resources are protected by Role Based Access Control (RBAC)"
}

output "force_destroy" {
  value       = konnect_portal.this.force_destroy
  description = "Whether the portal and all child entities will be deleted when running terraform destroy"
}

output "created_at" {
  value       = konnect_portal.this.created_at
  description = "An ISO-8601 timestamp representation of entity creation date"
}

output "updated_at" {
  value       = konnect_portal.this.updated_at
  description = "An ISO-8601 timestamp representation of entity update date"
}

output "portal" {
  value       = konnect_portal.this
  description = "The complete portal resource"
  sensitive   = false
}
