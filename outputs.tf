output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "The name of the S3 bucket"
}

output "s3_bucket_arn" {
  value       = module.s3.bucket_arn
  description = "The ARN of the S3 bucket"
}

output "s3_scripts_bucket_name" {
  value       = module.s3_scripts.bucket_name
  description = "The name of the S3 scripts bucket"
}

output "s3_lambda_trigger_function_name" {
  value       = module.s3_lambda_trigger.function_name
  description = "The name of the S3 Lambda trigger function"
}

output "s3_lambda_trigger_function_arn" {
  value       = module.s3_lambda_trigger.function_arn
  description = "The ARN of the S3 Lambda trigger function"
}

output "glue_crawler_name" {
  value       = module.glue_crawler.crawler_name
  description = "The name of the Glue crawler"
}

output "glue_database_name" {
  value       = module.glue_crawler.database_name
  description = "The name of the Glue database"
}

output "etl_job_name" {
  value       = module.etl_job.job_name
  description = "The name of the ETL job"
}

output "etl_job_arn" {
  value       = module.etl_job.job_arn
  description = "The ARN of the ETL job"
}

output "athena_workgroup_name" {
  value       = module.athena.workgroup_name
  description = "The name of the Athena workgroup"
}

output "athena_workgroup_arn" {
  value       = module.athena.workgroup_arn
  description = "The ARN of the Athena workgroup"
}

output "athena_table_name" {
  value       = module.athena.table_name
  description = "The name of the Athena table"
}

output "sns_topic_arn" {
  value       = module.sns_topic.topic_arn
  description = "The ARN of the SNS topic"
}

output "glue_crawler_succeeded_lambda_function_name" {
  value       = module.glue_crawler_succeeded_lambda.function_name
  description = "The name of the Glue crawler succeeded Lambda function"
}
