output "crawler_name" {
  value       = aws_glue_crawler.this[0].name
  description = "The name of the crawler"
}

output "crawler_arn" {
  value       = aws_glue_crawler.this[0].arn
  description = "The ARN of the crawler"
}

# output "job_name" {
#   value       = aws_glue_job.this.name
#   description = "The name of the job"
# }

# output "job_arn" {
#   value       = aws_glue_job.this.arn
#   description = "The ARN of the job"
# }
