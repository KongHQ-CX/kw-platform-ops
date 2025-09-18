variable "account_id" {
  description = "System account ID"
  type        = string
}

variable "entity_type_name" {
  description = "Entity type name (e.g., Control Planes, API Products, APIs)"
  type        = string
  default     = null
}

variable "role_name" {
  description = "Role name (e.g., Creator, Viewer, Publisher)"
  type        = string
  default     = null
}

variable "entity_id" {
  description = "Entity ID, or * for all"
  type        = string
  default     = null
}

variable "entity_region" {
  description = "Entity region (us, eu, au, me, in, *)"
  type        = string
  default     = null
}
