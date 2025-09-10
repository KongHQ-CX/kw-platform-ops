variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "theme_name" {
  description = "Theme name (mint_rocket|dark_mode|custom)"
  type        = string
  default     = null
}

variable "use_custom_fonts" {
  description = "Use custom fonts"
  type        = bool
  default     = null
}

variable "custom_fonts" {
  description = "Custom fonts block"
  type        = any
  default     = null
}

variable "custom_theme" {
  description = "Custom theme block"
  type        = any
  default     = null
}

variable "images" {
  description = "Images block (catalog_cover, favicon, logo)"
  type        = any
  default     = null
}

variable "text" {
  description = "Text block"
  type        = any
  default     = null
}
