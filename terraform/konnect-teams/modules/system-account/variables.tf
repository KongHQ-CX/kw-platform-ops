variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "team_id" {
  description = "The ID of the team"
  type        = string
}

variable "team_entitlements" {
  description = "The entitlements of the team"
  type        = list(string)
  default     = []
}
