variable "portal_id" {
  description = "The Portal identifier"
  type        = string
}

variable "name" {
  description = "Snippet name"
  type        = string
}

variable "content" {
  description = "Snippet markdown content"
  type        = string
}

variable "title" {
  description = "Snippet title"
  type        = string
  default     = null
}

variable "description" {
  description = "Snippet description"
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
