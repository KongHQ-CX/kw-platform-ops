variable "name" {
  description = "Realm name"
  type        = string
}

variable "allow_all_control_planes" {
  description = "Allow all control planes to use the realm"
  type        = bool
  default     = null
}

variable "allowed_control_planes" {
  description = "List of control plane IDs allowed to use the realm"
  type        = set(string)
  default     = []
}

variable "consumer_groups" {
  description = "Consumer groups automatically added to consumers in this realm"
  type        = set(string)
  default     = []
}

variable "ttl" {
  description = "Positive cache TTL (minutes) for consumer lookups"
  type        = number
  default     = null
}

variable "negative_ttl" {
  description = "Negative cache TTL (minutes) for failed consumer lookups"
  type        = number
  default     = null
}

variable "force_destroy" {
  description = "String flag (\"true\"|\"false\") controlling destructive destroy behavior"
  type        = string
  default     = null
}
