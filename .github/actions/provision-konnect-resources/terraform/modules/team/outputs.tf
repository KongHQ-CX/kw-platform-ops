output "id" {
  description = "The ID of the team."
  value       = konnect_team.this.id
}

output "name" {
  description = "The name of the team."
  value       = var.name
}
