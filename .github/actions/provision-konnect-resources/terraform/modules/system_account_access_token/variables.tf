variable "account_id" {
  description = "System account ID"
  type        = string
}

variable "name" {
  description = "Token name"
  type        = string
  default     = null
}

variable "expires_at" {
  description = "ISO8601 expiry timestamp"
  type        = string
  default     = null
}
