variable "name" {
  description = "The machine name of the integration instance that uniquely identifies it within the catalog."
  type        = string
}

variable "display_name" {
  description = "The display name of the integration instance."
  type        = string
}

variable "integration_name" {
  description = "The type of integration instance to create. Requires replacement if changed."
  type        = string
}

variable "description" {
  description = "Optionally provide a description of the integration instance."
  type        = string
  default     = null
}

variable "config" {
  description = "JSON string representing configuration specific to the integration instance (json-encoded object)."
  type        = string
}
