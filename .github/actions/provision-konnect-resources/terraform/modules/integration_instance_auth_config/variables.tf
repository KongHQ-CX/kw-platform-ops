variable "integration_instance_id" {
  description = "The id of the integration instance."
  type        = string
}

variable "oauth_config" {
  description = "OAuth config block for the integration auth config."
  type = object({
    authorization_endpoint = string
    client_id              = string
    client_secret          = string
    token_endpoint         = string
  })
  default = null
}
