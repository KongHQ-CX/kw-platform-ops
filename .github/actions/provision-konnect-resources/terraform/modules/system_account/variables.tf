variable "name" {
  description = "Name of the system account"
  type        = string
}

variable "description" {
  description = "Description of the system account"
  type        = string
  default     = null
}

variable "konnect_managed" {
  description = "Whether the system account is managed by Konnect"
  type        = bool
  default     = false
}
