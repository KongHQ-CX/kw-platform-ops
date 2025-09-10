output "id" {
  value       = konnect_system_account.this.id
  description = "System account ID"
}

output "name" {
  value       = var.name
  description = "System account name"
}
