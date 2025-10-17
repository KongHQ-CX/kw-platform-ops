variable "api_id" {
  description = "Identifier of the Konnect API the document belongs to."
  type        = string
}

variable "content" {
  description = "Markdown or HTML content of the API document."
  type        = string
}

variable "parent_document_id" {
  description = "Optional parent document identifier to nest this document."
  type        = string
  default     = null
}

variable "slug" {
  description = "Optional slug to use for the document URL."
  type        = string
  default     = null
}

variable "status" {
  description = "Optional publication status for the document."
  type        = string
  default     = null
}

variable "title" {
  description = "Optional display title for the document."
  type        = string
  default     = null
}
