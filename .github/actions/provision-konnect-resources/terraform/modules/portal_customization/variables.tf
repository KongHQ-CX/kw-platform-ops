variable "portal_id" {
  description = "The ID of the portal"
  type        = string
}

variable "css" {
  description = "Custom CSS for the portal"
  type        = string
  default     = null
}

variable "layout" {
  description = "Custom layout for the portal"
  type        = string
  default     = null
}

variable "robots" {
  description = "Robots.txt content for the portal"
  type        = string
  default     = null
}

variable "menu" {
  description = "Menu configuration for the portal"
  type = object({
    footer_bottom = optional(list(object({
      external   = bool
      path       = string
      title      = string
      visibility = string
    })))
    footer_sections = optional(list(object({
      title = string
      items = list(object({
        external   = bool
        path       = string
        title      = string
        visibility = string
      }))
    })))
    main = optional(list(object({
      external   = bool
      path       = string
      title      = string
      visibility = string
    })))
  })
  default = null
}

variable "spec_renderer" {
  description = "Spec renderer configuration"
  type = object({
    allow_custom_server_urls = optional(bool)
    hide_deprecated          = optional(bool)
    hide_internal            = optional(bool)
    infinite_scroll          = optional(bool)
    show_schemas             = optional(bool)
    try_it_insomnia          = optional(bool)
    try_it_ui                = optional(bool)
  })
  default = null
}

variable "theme" {
  description = "Theme configuration for the portal"
  type = object({
    mode = optional(string)
    name = optional(string)
    colors = optional(object({
      primary = optional(string)
    }))
  })
  default = null
}