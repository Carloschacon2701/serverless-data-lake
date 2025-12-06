# Package the Lambda function code
data "archive_file" "function" {
  type        = "zip"
  source_file = var.code_path
  output_path = "${path.module}/lambda/${var.function_name}.zip"
}


# Lambda function
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.function.output_path
  function_name    = var.function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = var.handler
  source_code_hash = data.archive_file.function.output_base64sha256

  runtime = var.runtime

  environment {
    variables = {
      for env in var.environment_variables : env.name => env.value
    }
  }

}
