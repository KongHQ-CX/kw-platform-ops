variable "api_id" {
  description = "The API ID to publish"
  type        = string
}

variable "portal_id" {
  description = "The portal ID where the API will be published"
  type        = string
}

variable "auth_strategy_ids" {
  description = "List of authentication strategy IDs for the API publication"
  type        = list(string)
  default     = null
}

variable "auto_approve_registrations" {
  description = "Whether to automatically approve registrations for this API publication"
  type        = bool
  default     = null
}

variable "visibility" {
  description = "The visibility of the API publication (private, public, etc.)"
  type        = string
  default     = "private"
}
