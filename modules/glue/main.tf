


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
  role          = aws_iam_role.iam_for_glue[0].arn

  s3_target {
    path = var.s3_target_path
  }
}



resource "aws_glue_job" "this" {
  count = var.create_job ? 1 : 0
  default_arguments = merge(
    {
      "--enable-glue-datacatalog"      = "true"
      "--enable-job-insights"          = "true"
      "--enable-metrics"               = "true"
      "--enable-observability-metrics" = "true"
      "--enable-spark-ui"              = "true"
      "--job-language"                 = "python"
    },
    var.etl_output_bucket_name != null ? {
      "--DATABASE_NAME"      = var.etl_database_name
      "--TABLE_NAME"         = var.etl_table_name
      "--OUTPUT_BUCKET_NAME" = var.etl_output_bucket_name
      "--OUTPUT_PREFIX"      = var.etl_output_prefix
    } : {}
  )
  description       = "ETL job for ${var.project_name}"
  execution_class   = "STANDARD"
  glue_version      = "5.0"
  job_mode          = "VISUAL"
  max_retries       = 0
  name              = var.job_name
  number_of_workers = 2
  role_arn          = aws_iam_role.iam_for_etl_job[0].arn
  timeout           = 480
  worker_type       = "G.1X"
  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.s3_scripts_bucket_name}/etljob.py"
  }
  execution_property {
    max_concurrent_runs = 1
  }
}
