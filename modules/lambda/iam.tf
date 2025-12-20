
locals {
  create_role_policy = var.role_attributes != null && length(var.role_attributes) > 0 ? 1 : 0
}

########################################################
# Lambda Role
########################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "lambda_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  count = local.create_role_policy
  role  = aws_iam_role.iam_for_lambda.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for attr in var.role_attributes : {
        Action   = attr.actions
        Effect   = attr.effect
        Resource = attr.resources
      }
    ]
  })
}

resource "random_id" "lambda_role_name" {
  byte_length = 8
  prefix      = "${var.project_name}-lambda-role-terraform"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = random_id.lambda_role_name.id
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.lambda_policy.arn
  depends_on = [aws_iam_role.iam_for_lambda]
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_${var.function_name}"
  path        = "/"
  description = "IAM policy for logging from Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
  depends_on = [aws_iam_role.iam_for_lambda]
}
