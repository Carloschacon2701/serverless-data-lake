output "function_name" {

  value       = aws_lambda_function.function.function_name
  description = "The name of the function"
}

output "function_arn" {
  value       = aws_lambda_function.function.arn
  description = "The ARN of the function"
}
