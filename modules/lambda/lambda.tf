# Package the Lambda function code
data "archive_file" "function" {
  type        = "zip"
  source_file = var.code_path
  output_path = "${path.module}/lambda/${var.function_name}.zip"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = {
    Environment = var.project_name
    Function    = var.function_name
  }
}


# Lambda function
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.function.output_path
  function_name    = var.function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = var.handler
  source_code_hash = data.archive_file.function.output_base64sha256
  timeout          = 15
  runtime          = var.runtime

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  environment {
    variables = {
      for env in var.environment_variables : env.name => env.value
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group, aws_iam_role_policy_attachment.lambda_logging_policy_attachment, aws_iam_role_policy_attachment.lambda_policy_attachment]

}
