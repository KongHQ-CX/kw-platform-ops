variable "portal_id" {
  description = "The portal ID to attach the custom domain to"
  type        = string
}

variable "hostname" {
  description = "The hostname to use for the portal"
  type        = string
}

variable "enabled" {
  description = "Whether the custom domain is enabled"
  type        = bool
  default     = false
}

variable "ssl_type" {
  description = "SSL type for the custom domain. Typically 'managed' or 'bring-your-own'"
  type        = string
  default     = "managed"
}
