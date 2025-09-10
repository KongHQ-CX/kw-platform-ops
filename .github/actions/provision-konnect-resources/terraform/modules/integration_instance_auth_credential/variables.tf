variable "integration_instance_id" {
  description = "The id of the integration instance."
  type        = string
}

variable "multi_key_auth" {
  description = "Payload for Multi Key authorization strategy credential."
  type = object({
    config = object({
      headers = list(object({
        name = string
        key  = string
      }))
    })
  })
  default = null
}
