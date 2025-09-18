variable "name" {
  description = "The name of the audit log destination."
  type        = string
}

variable "endpoint" {
  description = "The endpoint that will receive audit log messages."
  type        = string
}

variable "authorization" {
  description = "The value to include in the Authorization header when sending audit logs to the webhook."
  type        = string
  default     = null
}

variable "log_format" {
  description = "The output format of each log message. One of: cef, json, cps."
  type        = string
  default     = null
}

variable "skip_ssl_verification" {
  description = "Skip SSL verification for the destination endpoint (not recommended for production)."
  type        = bool
  default     = null
}
