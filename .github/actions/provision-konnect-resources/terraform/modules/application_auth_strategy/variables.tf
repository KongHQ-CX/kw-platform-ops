variable "name" {
  description = "The name of the auth strategy. Used to identify it in the Konnect UI."
  type        = string
}

variable "display_name" {
  description = "The display name of the Auth strategy. Used in the Portal UI."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels for metadata and filtering."
  type        = map(string)
  default     = {}
}

variable "strategy_type" {
  description = "Strategy type to create. One of: key_auth, openid_connect"
  type        = string
  validation {
    condition     = contains(["key_auth", "openid_connect"], var.strategy_type)
    error_message = "strategy_type must be one of: key_auth, openid_connect"
  }
}

variable "key_auth_key_names" {
  description = "Header names to look for API keys when using key_auth."
  type        = list(string)
  default     = []
}

variable "oidc_dcr_provider_id" {
  description = "DCR provider id to associate with the OIDC strategy."
  type        = string
  default     = null
}

variable "oidc_additional_properties" {
  description = "Additional OIDC properties as JSON string."
  type        = string
  default     = null
}

variable "oidc_auth_methods" {
  description = "OIDC auth methods."
  type        = list(string)
  default     = []
}

variable "oidc_credential_claim" {
  description = "OIDC credential claims."
  type        = list(string)
  default     = []
}

variable "oidc_issuer" {
  description = "OIDC issuer URL."
  type        = string
  default     = null
}

variable "oidc_scopes" {
  description = "OIDC scopes."
  type        = list(string)
  default     = []
}
