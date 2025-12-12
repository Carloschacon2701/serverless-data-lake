


########################################################
# Glue Catalog Database
########################################################
resource "aws_glue_catalog_database" "this" {
  count = var.create_crawler ? 1 : 0
  name  = var.database_name
}

########################################################
# Glue Crawler
########################################################
resource "aws_glue_crawler" "this" {
  count         = var.create_crawler ? 1 : 0
  database_name = aws_glue_catalog_database.this[0].name
  name          = var.crawler_name
  role          = aws_iam_role.iam_for_glue.arn

  s3_target {
    path = var.s3_target_path
  }
}

