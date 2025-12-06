variable "project_name" {
  type        = string
  description = "The name of the project"
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must be at least 1 character long"
  }

}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket"
  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "Bucket name must be at least 1 character long"
  }

}

variable "create_lambda_triger" {
  type        = bool
  description = "Determines if a lambda trigger should be created for the bucket"
  default     = false
}

variable "lambda_function_arn" {
  type        = string
  description = "The ARN of the lambda function to trigger"
  validation {
    condition     = var.create_lambda_triger ? length(var.lambda_function_arn) > 0 : true
    error_message = "Lambda function ARN must be provided when create_lambda_triger is true"
  }
}
