output "created_at" {
  description = "The creation timestamp of the API publication"
  value       = konnect_api_publication.this.created_at
}

output "updated_at" {
  description = "The last update timestamp of the API publication"
  value       = konnect_api_publication.this.updated_at
}

output "api_publication" {
  description = "The complete API publication resource"
  value       = konnect_api_publication.this
}
