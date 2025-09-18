variable "name" {
  description = "Control Plane name"
  type        = string
}

variable "description" {
  description = "Control Plane description"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to the Control Plane"
  type        = map(string)
  default     = {}
}

variable "cluster_type" {
  description = "Konnect Gateway cluster type (e.g., CLUSTER_TYPE_HYBRID or CLUSTER_TYPE_KONNECT)"
  type        = string
  default     = "CLUSTER_TYPE_HYBRID"
}

variable "auth_type" {
  description = "Authentication type for data planes (e.g., pki_client_certs, tokens)"
  type        = string
  default     = "pki_client_certs"
}

variable "cloud_gateway" {
  description = "Whether this control plane is a Konnect Cloud Gateway"
  type        = bool
  default     = false
}

variable "team" {
  description = "The team to assign the resources to"
  type = object({
    id   = string
    name = string
  })
}
