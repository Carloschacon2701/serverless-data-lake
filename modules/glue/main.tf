locals {
  create_crawler  = var.crawler_name != null
  create_database = var.database_name != null
}


resource "aws_glue_catalog_database" "this" {
  count = local.create_database ? 1 : 0
  name  = var.database_name
}

########################################################
# Glue Crawler
########################################################
resource "aws_glue_crawler" "this" {
  count         = local.create_crawler ? 1 : 0
  database_name = aws_glue_catalog_database.this.name
  name          = var.crawler_name
  role          = var.role

  s3_target {
    path = var.s3_target_path
  }
}
