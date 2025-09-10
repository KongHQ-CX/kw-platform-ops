variable "endpoint" {
  description = "The endpoint that will receive audit log messages."
  type        = string
  default     = null
}

variable "authorization" {
  description = "The value to include in the Authorization header when sending audit logs to the webhook."
  type        = string
  default     = null
}

variable "enabled" {
  description = "Indicates if the data should be sent to the webhook. Default: false"
  type        = bool
  default     = null
}

variable "log_format" {
  description = "The output format of each log message. One of: cef, json, cps."
  type        = string
  default     = null
}

variable "skip_ssl_verification" {
  description = "Skip SSL verification for the endpoint (not recommended for production)."
  type        = bool
  default     = null
}
