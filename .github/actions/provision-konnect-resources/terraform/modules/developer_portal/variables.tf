variable "name" {
  description = "The name of the Developer Portal"
  type        = string
}

variable "description" {
  description = "Description for the portal"
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to attach to the portal"
  type        = map(string)
  default     = {}
}
