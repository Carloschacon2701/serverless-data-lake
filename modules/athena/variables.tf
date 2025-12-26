variable "project_name" {
  type        = string
  description = "The name of the project"
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must be at least 1 character long"
  }
}

variable "workgroup_name" {
  type        = string
  description = "The name of the workgroup"
  validation {
    condition     = length(var.workgroup_name) > 0
    error_message = "Workgroup name must be at least 1 character long"
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

variable "bucket_name" {
  type        = string
  description = "The name of the bucket"
  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "Bucket name must be at least 1 character long"
  }
}

variable "columns" {
  type = list(object({
    name = string
    type = string
  }))
  description = "The columns of the table"
  default     = []
}
