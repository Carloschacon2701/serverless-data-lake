variable "project_name" {
  type        = string
  description = "The name of the project"
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must be at least 1 character long"
  }

}

variable "function_name" {
  type        = string
  description = "The name of the function"
  validation {
    condition     = length(var.function_name) > 0
    error_message = "Function name must be at least 1 character long"
  }

}

variable "handler" {
  type        = string
  description = "The handler of the function"
  validation {
    condition     = length(var.handler) > 0
    error_message = "Handler must be at least 1 character long"
  }

}

variable "runtime" {
  type        = string
  description = "The runtime of the function"
  validation {
    condition     = length(var.runtime) > 0
    error_message = "Runtime must be at least 1 character long"
  }

}

variable "code_path" {
  type        = string
  description = "The path to the code for the function"
  validation {
    condition     = length(var.code_path) > 0
    error_message = "Code path must be at least 1 character long"
  }
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables for the function"
  default     = []
}

variable "role_attributes" {
  type = list(object({
    actions   = list(string)
    effect    = string
    resources = list(string)
  }))
  description = "The role attributes for the lambda function"
  default     = []
}

variable "error_handling" {
  type        = bool
  description = "Determines if the function should handle errors"
  default     = false
}
