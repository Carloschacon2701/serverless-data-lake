output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "The name of the S3 bucket"
}

output "s3_lambda_trigger_function_name" {
  value       = module.s3_lambda_trigger.function_name
  description = "The name of the Lambda function"
}
