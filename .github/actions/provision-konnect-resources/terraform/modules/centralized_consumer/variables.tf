variable "realm_id" {
  description = "Realm ID"
  type        = string
}

variable "username" {
  description = "Unique username of the consumer"
  type        = string
}

variable "custom_id" {
  description = "Custom ID for mapping to external identity"
  type        = string
  default     = null
}

variable "consumer_type" {
  description = "Type of consumer (proxy|developer|admin|application)"
  type        = string
  default     = null
}

variable "consumer_groups" {
  description = "List of consumer groups the consumer belongs to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for the consumer"
  type        = list(string)
  default     = []
}
