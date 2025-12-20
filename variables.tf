variable "sns_topic_email_endpoint" {
  type        = string
  description = "Email address to subscribe to the SNS topic for notifications"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.sns_topic_email_endpoint))
    error_message = "The SNS topic email address must be a valid email format."
  }
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must be at least 1 character long"
  }
}
