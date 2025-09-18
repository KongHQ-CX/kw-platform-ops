variable "portal_id" {
  description = "The portal ID to configure auth for"
  type        = string
}

variable "basic_auth_enabled" {
  description = "Enable Basic Auth for the portal"
  type        = bool
  default     = null
}

variable "oidc_auth_enabled" {
  description = "Enable OIDC for the portal"
  type        = bool
  default     = null
}

variable "oidc_issuer" {
  description = "OIDC Issuer URL"
  type        = string
  default     = null
}

variable "oidc_client_id" {
  description = "OIDC Client ID"
  type        = string
  default     = null
}

variable "oidc_client_secret" {
  description = "OIDC Client Secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "oidc_scopes" {
  description = "OIDC scopes"
  type        = list(string)
  default     = []
}

variable "oidc_team_mapping_enabled" {
  description = "Whether IdP groups determine the Konnect Portal teams a developer has"
  type        = bool
  default     = null
}

variable "idp_mapping_enabled" {
  description = "Whether IdP mapping is enabled (newer flag replacing oidc_team_mapping_enabled)"
  type        = bool
  default     = null
}

variable "konnect_mapping_enabled" {
  description = "Whether a Konnect Identity Admin assigns teams to a developer"
  type        = bool
  default     = null
}

variable "oidc_claim_mappings" {
  description = "Mappings from a portal developer attribute to an IdP claim"
  type = object({
    email  = optional(string)
    groups = optional(string)
    name   = optional(string)
  })
  default = null
}

variable "saml_auth_enabled" {
  description = "Enable SAML for the portal"
  type        = bool
  default     = null
}
