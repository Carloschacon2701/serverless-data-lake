variable "project_name" {
  type        = string
  description = "The name of the project"
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must be at least 1 character long"
  }

}

variable "crawler_name" {
  type        = string
  description = "The name of the crawler"
  default     = null

  validation {
    condition     = var.crawler_name != null ? length(var.crawler_name) > 0 : true
    error_message = "Crawler name must be provided when crawler_name is not null"
  }
}

variable "database_name" {
  type        = string
  description = "The name of the database"
  validation {
    condition     = length(var.database_name) > 0
    error_message = "Database name must be at least 1 character long"
  }
}


variable "s3_target_path" {
  type        = string
  description = "The path of the S3 target"
  validation {
    condition     = length(var.s3_target_path) > 0
    error_message = "S3 target path must be at least 1 character long"
  }
}
