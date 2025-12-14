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

resource "random_id" "lambda_role_name" {
  byte_length = 8
  prefix      = "${var.project_name}-lambda-role-terraform-"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = random_id.lambda_role_name.id
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

