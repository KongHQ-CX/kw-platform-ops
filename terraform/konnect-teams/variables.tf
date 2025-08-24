// variables.tf
variable "konnect_region" {
  description = "The region to create the resources in"
  default     = "eu"
  type        = string
}

variable "resources_path" {
  description = "Path to the resources directory"
  type        = string
}
