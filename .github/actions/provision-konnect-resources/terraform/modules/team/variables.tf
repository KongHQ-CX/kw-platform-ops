variable "name" {
  description = "A name for the team being created."
  type        = string
}

variable "description" {
  description = "The description of the new team."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels for the team."
  type        = map(string)
  default     = {}
}
