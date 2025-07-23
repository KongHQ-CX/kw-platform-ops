// variables.tf
variable "konnect_region" {
  description = "The region to create the resources in"
  default     = "eu"
  type        = string
}

variable "config_file" {
  description = "Path to the configuration file"
  type        = string
  default     = "./files/empty.yaml" # Default to an empty file if not provided
}
