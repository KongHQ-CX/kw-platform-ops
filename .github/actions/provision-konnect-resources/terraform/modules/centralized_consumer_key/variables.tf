variable "realm_id" {
  description = "Realm ID"
  type        = string
}

variable "consumer_id" {
  description = "Centralized consumer ID"
  type        = string
}

variable "key_type" {
  description = "Key type (new|legacy)"
  type        = string
  default     = null
}

variable "secret" {
  description = "Optional explicit secret; provider can auto-generate if omitted"
  type        = string
  sensitive   = true
  default     = null
}

variable "tags" {
  description = "Tags for the key"
  type        = list(string)
  default     = []
}
