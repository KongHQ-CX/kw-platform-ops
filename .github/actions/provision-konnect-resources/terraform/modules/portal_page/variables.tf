variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "slug" {
  description = "Page slug"
  type        = string
}

variable "content" {
  description = "Markdown content"
  type        = string
}

variable "title" {
  description = "Page title"
  type        = string
  default     = null
}

variable "description" {
  description = "Page description"
  type        = string
  default     = null
}

variable "parent_page_id" {
  description = "Optional parent page id"
  type        = string
  default     = null
}

variable "status" {
  description = "Publish status (published|unpublished)"
  type        = string
  default     = null
}

variable "visibility" {
  description = "Visibility (public|private)"
  type        = string
  default     = null
}
