########################################################
# Archive File for Lambda Function
########################################################
data "archive_file" "function" {
  type        = "zip"
  source_file = var.code_path
  output_path = "${path.module}/lambda/${var.function_name}.zip"
}

########################################################
# CloudWatch Log Group for Lambda
########################################################
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = {
    Environment = var.project_name
    Function    = var.function_name
  }
}

########################################################
# Lambda Function
########################################################
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

  dynamic "dead_letter_config" {
    for_each = var.error_handling ? [1] : []
    content {
      target_arn = aws_sqs_queue.lambda_dlq[0].arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_role_policy_attachment.lambda_logging_policy_attachment,
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]

}

########################################################
# Lambda Dead Letter Queue
########################################################
resource "aws_sqs_queue" "lambda_dlq" {
  count = var.error_handling ? 1 : 0

  name                      = "${var.function_name}-dlq"
  message_retention_seconds = 1209600 # 14 days (max retention)

  tags = {
    Environment = var.project_name
    Function    = var.function_name
    Purpose     = "DeadLetterQueue"
  }
}

########################################################
# Lambda DLQ IAM Role Policy
########################################################
resource "aws_iam_role_policy" "lambda_dlq_policy" {
  count = var.error_handling ? 1 : 0
  name  = "${var.function_name}-dlq-policy"
  role  = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.lambda_dlq[0].arn
      }
    ]
  })

  depends_on = [aws_iam_role.iam_for_lambda]
}

########################################################
# Lambda Function Event Invoke Config
########################################################
resource "aws_lambda_function_event_invoke_config" "function_event_invoke_config" {
  count                        = var.error_handling ? 1 : 0
  function_name                = aws_lambda_function.function.function_name
  maximum_retry_attempts       = 2
  maximum_event_age_in_seconds = 60

  destination_config {
    on_failure {
      destination = aws_sqs_queue.lambda_dlq[0].arn
    }
  }

  depends_on = [aws_lambda_function.function, aws_sqs_queue.lambda_dlq]
}
