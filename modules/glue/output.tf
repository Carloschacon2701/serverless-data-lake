output "crawler_name" {
  value       = var.create_crawler ? aws_glue_crawler.this[0].name : null
  description = "The name of the crawler"
}

output "crawler_arn" {
  value       = var.create_crawler ? aws_glue_crawler.this[0].arn : null
  description = "The ARN of the crawler"
}

output "database_name" {
  value       = var.create_crawler ? aws_glue_catalog_database.this[0].name : null
  description = "The name of the Glue database"
}

# output "job_name" {
#   value       = aws_glue_job.this.name
#   description = "The name of the job"
# }

# output "job_arn" {
#   value       = aws_glue_job.this.arn
#   description = "The ARN of the job"
# }
