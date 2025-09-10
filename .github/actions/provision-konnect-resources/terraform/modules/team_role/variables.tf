variable "team_id" {
  description = "The team ID."
  type        = string
}

variable "entity_type_name" {
  description = "The type of entity."
  type        = string
  default     = null
}

variable "role_name" {
  description = "The desired role."
  type        = string
  default     = null
}

variable "entity_id" {
  description = "The ID of the entity."
  type        = string
  default     = null
}

variable "entity_region" {
  description = "Region of the team."
  type        = string
  default     = null
}
