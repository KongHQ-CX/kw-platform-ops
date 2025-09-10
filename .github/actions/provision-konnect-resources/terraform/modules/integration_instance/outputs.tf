output "integration_instance" {
  description = "Whole integration instance object"
  value = {
    id           = konnect_integration_instance.this.id
    name         = konnect_integration_instance.this.name
    display_name = konnect_integration_instance.this.display_name
  }
}
