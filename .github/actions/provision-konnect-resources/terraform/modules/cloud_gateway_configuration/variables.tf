variable "control_plane_id" {
  description = "ID of the Konnect control plane to attach"
  type        = string
}

variable "control_plane_geo" {
  description = "Geographic location for the control plane routing"
  type        = string
}

variable "dataplane_groups" {
  description = "Map of dataplane group configurations"
  type        = any
}

variable "config_version" {
  description = "Configuration version string"
  type        = string
}

