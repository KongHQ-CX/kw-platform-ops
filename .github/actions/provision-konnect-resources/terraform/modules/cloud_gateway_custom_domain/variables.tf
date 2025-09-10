variable "control_plane_id" {
  description = "ID of the Konnect control plane"
  type        = string
}

variable "control_plane_geo" {
  description = "Control-plane geo for the custom domain (us|eu|au|me|in)"
  type        = string
}

variable "domain" {
  description = "Domain name of the custom domain"
  type        = string
}
