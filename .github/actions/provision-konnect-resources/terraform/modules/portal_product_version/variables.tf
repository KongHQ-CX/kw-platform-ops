variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "product_version_id" {
  description = "API product version identifier"
  type        = string
}

variable "publish_status" {
  description = "Publication status (published|unpublished)"
  type        = string
}

variable "application_registration_enabled" {
  description = "Whether application registration is enabled"
  type        = bool
}

variable "auto_approve_registration" {
  description = "Whether auto-approve registration is enabled"
  type        = bool
}

variable "deprecated" {
  description = "Whether the product version is deprecated"
  type        = bool
}

variable "auth_strategy_ids" {
  description = "List of auth strategy IDs"
  type        = list(string)
}

variable "notify_developers" {
  description = "Whether to notify affected developers"
  type        = bool
  default     = null
}
