data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

########################################################
# Glue Assume Role Policy
########################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

########################################################
# Cloudwatch Full Access
########################################################
data "aws_iam_policy" "cloudwatch_full_access" {
  name = "CloudWatchFullAccess"
}

########################################################
# Cloudwatch Full Access
########################################################
resource "aws_iam_role_policy" "cloudwatch_full_access" {
  role       = aws_iam_role.iam_for_glue.id
  policy     = data.aws_iam_policy.cloudwatch_full_access.arn
  depends_on = [aws_iam_role.iam_for_glue]
}


########################################################
# Glue Access Policy
########################################################
data "aws_iam_role_policy" "glue_access_policy" {
  role = aws_iam_role.iam_for_glue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions",
          "glue:CreatePartition",
          "glue:UpdatePartition",
          "glue:DeletePartition"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:glue:${local.region}:${local.account_id}:database/${var.database_name}",
          "arn:aws:glue:${local.region}:${local.account_id}:table/${var.database_name}/*",
          "arn:aws:glue:${local.region}:${local.account_id}:catalog"
        ]
      },
    ]
  })
  depends_on = [aws_iam_role.iam_for_glue]
}


########################################################
# Glue Role
########################################################

resource "aws_iam_role" "iam_for_glue" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "${var.project_name}-glue-role"
  path               = "/service-role/"
}
