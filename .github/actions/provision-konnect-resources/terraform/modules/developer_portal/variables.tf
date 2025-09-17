variable "name" {
  description = "The name of the Developer Portal"
  type        = string
}

variable "description" {
  description = "Description for the portal"
  type        = string
  default     = null
}

variable "display_name" {
  description = "The display name of the portal. This value will be the portal's `name` in Portal API."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to attach to the portal"
  type        = map(string)
  default     = {}
}

variable "authentication_enabled" {
  description = "Whether the portal supports developer authentication. If disabled, developers cannot register for accounts or create applications. Default: true"
  type        = bool
  default     = null
}

variable "auto_approve_applications" {
  description = "Whether requests from applications to register for APIs will be automatically approved, or if they will be set to pending until approved by an admin. Default: false"
  type        = bool
  default     = null
}

variable "auto_approve_developers" {
  description = "Whether developer account registrations will be automatically approved, or if they will be set to pending until approved by an admin. Default: false"
  type        = bool
  default     = null
}

variable "default_api_visibility" {
  description = "The default visibility of APIs in the portal. If set to `public`, newly published APIs are visible to unauthenticated developers. If set to `private`, newly published APIs are hidden from unauthenticated developers. must be one of [\"public\", \"private\"]"
  type        = string
  default     = null
  validation {
    condition     = var.default_api_visibility == null || contains(["public", "private"], var.default_api_visibility)
    error_message = "default_api_visibility must be either 'public' or 'private'."
  }
}

variable "default_application_auth_strategy_id" {
  description = "The default authentication strategy for APIs published to the portal. Newly published APIs will use this authentication strategy unless overridden during publication. If set to `null`, API publications will not use an authentication strategy unless set during publication."
  type        = string
  default     = null
}

variable "default_page_visibility" {
  description = "The default visibility of pages in the portal. If set to `public`, newly created pages are visible to unauthenticated developers. If set to `private`, newly created pages are hidden from unauthenticated developers. must be one of [\"public\", \"private\"]"
  type        = string
  default     = null
  validation {
    condition     = var.default_page_visibility == null || contains(["public", "private"], var.default_page_visibility)
    error_message = "default_page_visibility must be either 'public' or 'private'."
  }
}

variable "rbac_enabled" {
  description = "Whether the portal resources are protected by Role Based Access Control (RBAC). If enabled, developers view or register for APIs until unless assigned to teams with access to view and consume specific APIs. Authentication must be enabled to use RBAC. Default: false"
  type        = bool
  default     = null
}

variable "force_destroy" {
  description = "If set to \"true\", the portal and all child entities will be deleted when running `terraform destroy`. If set to \"false\", the portal will not be deleted until all child entities are manually removed. This will IRREVERSIBLY DELETE ALL REGISTERED DEVELOPERS AND THEIR CREDENTIALS. Only set to \"true\" if you want this behavior. Default: \"false\"; must be one of [\"true\", \"false\"]"
  type        = string
  default     = null
  validation {
    condition     = var.force_destroy == null || contains(["true", "false"], var.force_destroy)
    error_message = "force_destroy must be either 'true' or 'false'."
  }
}
