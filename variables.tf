variable "sns_topic_email_endpoint" {
  type        = string
  description = "Email address to subscribe to the SNS topic for notifications"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.sns_email_endpoint))
    error_message = "The email address must be a valid email format."
  }
}
