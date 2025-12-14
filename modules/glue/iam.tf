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
# Administrator Access
########################################################
data "aws_iam_policy" "admin_access" {
  name = "AdministratorAccess"
}

########################################################
# ETL job Role
########################################################
resource "aws_iam_role" "iam_for_etl_job" {
  count              = var.create_job ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "${var.project_name}-etl-job-role"
  path               = "/service-role/"
}

########################################################
# ETL job Access Policy Attachment
########################################################
resource "aws_iam_role_policy_attachment" "etl_job_admin_access" {
  count      = var.create_job ? 1 : 0
  role       = aws_iam_role.iam_for_etl_job[0].name
  policy_arn = data.aws_iam_policy.admin_access.arn
}


########################################################
# Glue Role
########################################################

resource "aws_iam_role" "iam_for_glue" {
  count              = var.create_crawler ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "${var.project_name}-glue-role"
  path               = "/service-role/"
}


########################################################
# Cloudwatch Full Access Policy Attachment
########################################################
resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  count      = var.create_crawler ? 1 : 0
  role       = aws_iam_role.iam_for_glue[0].name
  policy_arn = data.aws_iam_policy.cloudwatch_full_access.arn
}


########################################################
# Glue Access Policy
########################################################
resource "aws_iam_role_policy" "glue_access_policy" {
  count = var.create_crawler ? 1 : 0
  role  = aws_iam_role.iam_for_glue[0].id
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
  depends_on = [aws_iam_role.iam_for_glue[0]]
}
