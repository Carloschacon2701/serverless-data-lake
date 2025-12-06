output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "The name of the S3 bucket"
}

output "lambda_function_name" {
  value       = module.lambda.function_name
  description = "The name of the Lambda function"
}
