variable "name" {
  description = "The name of your API. The name + version combination must be unique for each API you publish"
  type        = string
}

variable "description" {
  description = "A description of your API. Will be visible on your live Portal"
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels store metadata of an entity that can be used for filtering an entity list or for searching across entity types. Keys must be of length 1-63 characters, and cannot start with 'kong', 'konnect', 'mesh', 'kic', or '_'"
  type        = map(string)
  default     = {}
}

variable "slug" {
  description = "The slug is used in generated URLs to provide human readable paths. Defaults to slugify(name + version)"
  type        = string
  default     = null
}

variable "spec_content" {
  description = "The content of the API specification. This is the raw content of the API specification, in json or yaml. By including this field, you can add a API specification without having to make a separate call to update the API specification. Requires replacement if changed"
  type        = string
  default     = null
}

variable "api_version" {
  description = "Alias of version to avoid conflicts with module meta-arg names in callers"
  type        = string
  default     = null
}

variable "portals" {
  description = "A list of portals to publish this API to. If empty, the API will not be published to any portal"
  type        = list(any)
  default     = []
}
