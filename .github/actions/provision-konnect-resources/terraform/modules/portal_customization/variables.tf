variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "css" {
  description = "Custom CSS to inject"
  type        = string
  default     = null
}

variable "layout" {
  description = "Portal layout"
  type        = string
  default     = null
}

variable "robots" {
  description = "Robots.txt content"
  type        = string
  default     = null
}

variable "menu" {
  description = "Menu configuration block (matches provider schema)"
  type        = any
  default     = null
}

variable "spec_renderer" {
  description = "Spec renderer configuration block"
  type        = any
  default     = null
}

variable "theme" {
  description = "Theme configuration block"
  type        = any
  default     = null
}
