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
    condition     = var.create_crawler ? length(var.crawler_name) > 0 : true
    error_message = "Crawler name must be provided when crawler_name is not null"
  }
}

variable "database_name" {
  type        = string
  description = "The name of the database"
  default     = null
  validation {
    condition     = var.create_crawler ? length(var.database_name) > 0 : true
    error_message = "Database name must be at least 1 character long"
  }
}


variable "s3_target_path" {
  type        = string
  description = "The path of the S3 target"
  default     = null
  validation {
    condition     = var.create_crawler ? length(var.s3_target_path) > 0 : true
    error_message = "S3 target path must be at least 1 character long"
  }
}

variable "create_crawler" {
  type        = bool
  description = "Determines if a crawler should be created"
  default     = false
}

variable "create_job" {
  type        = bool
  description = "Determines if a job should be created"
  default     = false
}

variable "job_name" {
  type        = string
  description = "The name of the job"
  default     = null
  validation {
    condition     = var.create_job ? length(var.job_name) > 0 : true
    error_message = "Job name must be at least 1 character long"
  }
}
