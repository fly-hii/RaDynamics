# IAM Group Variables

variable "group_name" {
  description = "Name of the IAM group"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.group_name))
    error_message = "Group name must contain only alphanumeric characters and +=,.@_- symbols."
  }
}

variable "path" {
  description = "Path for the IAM group"
  type        = string
  default     = "/"
  
  validation {
    condition     = can(regex("^/.*/$", var.path)) || var.path == "/"
    error_message = "Path must start and end with forward slash (/)."
  }
}

variable "attached_policies" {
  description = "List of AWS managed policy ARNs to attach to the group"
  type        = list(string)
  default     = []
}

variable "additional_tags" {
  description = "Additional tags to apply to the IAM group"
  type        = map(string)
  default     = {}
}