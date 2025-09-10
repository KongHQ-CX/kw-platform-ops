variable "api_id" {
  description = "The UUID of the API to which this version belongs."
  type        = string
}

variable "api_version" {
  description = "The version string (e.g., 1.0.0)."
  type        = string
  default     = null
}

variable "spec_content" {
  description = "Raw spec content (OpenAPI/AsyncAPI) for this API version."
  type        = string
}
