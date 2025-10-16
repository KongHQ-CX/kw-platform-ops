variable "name" {
  description = "Dashboard name used for Konnect UI."
  type        = string
}

variable "labels" {
  description = "Optional labels applied to the dashboard for filtering."
  type        = map(string)
  default     = {}
}

variable "definition" {
  description = "Full dashboard definition object matching the konnect_dashboard schema."
  type        = any
}
