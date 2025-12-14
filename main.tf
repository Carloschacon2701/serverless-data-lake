########################################################
# S3 Bucket Raw
########################################################
module "s3" {
  source               = "./modules/s3"
  project_name         = "data-lake-serverless"
  bucket_name          = "data-lake-serverless"
  create_lambda_triger = true
  lambda_function_arn  = module.s3_lambda_trigger.function_arn

}

########################################################
# S3 Bucket Processed
########################################################
module "s3_processed" {
  source       = "./modules/s3"
  project_name = "data-lake-serverless"
  bucket_name  = "data-lake-serverless-processed"
}

########################################################
# S3 for scripts
########################################################
module "s3_scripts" {
  source       = "./modules/s3"
  project_name = "data-lake-serverless"
  bucket_name  = "data-lake-serverless-scripts"
}

########################################################
# S3 Lambda Trigger
########################################################
module "s3_lambda_trigger" {
  source        = "./modules/lambda"
  project_name  = "data-lake-serverless"
  function_name = "data-lake-serverless"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  code_path     = "./lambda/index.mjs"
  environment_variables = [
    {
      name  = "CRAWLER_NAME"
      value = "crawler-datalake"
    }
  ]
}

########################################################
# Glue Crawler
########################################################
module "glue_crawler" {
  source         = "./modules/glue"
  project_name   = "data-lake-serverless"
  database_name  = "data-lake"
  crawler_name   = "crawler-datalake"
  s3_target_path = "s3://${module.s3.bucket_name}"
}

########################################################
# Glue Crawler Succeeded Lambda
########################################################
module "glue_crawler_succeeded_lambda" {
  source        = "./modules/lambda"
  project_name  = "data-lake-serverless"
  function_name = "glue-crawler-succeeded"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  code_path     = "./lambda/crawlerTrigger.mjs"
  environment_variables = [
    {
      name  = "JOB_NAME"
      value = "glue-job-datalake"
    }
  ]
}

########################################################
# SNS Topic
########################################################
module "sns_topic" {
  source = "terraform-aws-modules/sns/aws"

  name = "data-lake-serverless"

  subscriptions = {
    email_subscription = {
      protocol = "email"
      endpoint = var.sns_topic_email_endpoint
    }
  }
}

########################################################
# EventBridge
########################################################
module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = "data-lake-serverless"


  rules = {
    glue_crawler_succeeded = {
      description = "Capture Glue Crawler state change when crawler succeeds"
      event_pattern = jsonencode({
        "source"      = ["aws.glue"]
        "detail-type" = ["Glue Crawler State Change"]
        "detail" = {
          "crawlerName" = [module.glue_crawler.crawler_name]
          "state"       = ["Succeeded"]
        }
      })
      enabled = true
    }

    etl_job_succeeded = {
      description = "Capture ETL job state change when job succeeds"
      event_pattern = jsonencode({
        "source"      = ["aws.glue"]
        "detail-type" = ["Glue Job State Change"]
        "detail" = {
          "jobName" = ["ETL-datalake"]
          "state"   = ["SUCCEEDED"]
        }
      })
      enabled = true
    }
  }

  targets = {
    glue_crawler_succeeded = {
      arn = module.glue_crawler_succeeded_lambda.function_arn
    }

    etl_job_succeeded = {
      arn = module.sns_topic.topic_arn
    }
  }
}

########################################################
# Glue ETL Job
########################################################
resource "aws_glue_job" "etl_job" {
  name     = "ETL-datalake"
  role_arn = "arn:aws:iam::<id>:role/ETL-job-Role" # Update with your IAM role ARN

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://aws-glue-assets-<id>-us-east-1/scripts/ETL-datalake.py"
  }

  default_arguments = {
    "--enable-glue-datacatalog"      = "true"
    "--enable-job-insights"          = "true"
    "--enable-metrics"               = "true"
    "--enable-observability-metrics" = "true"
    "--enable-spark-ui"              = "true"
    "--job-language"                 = "python"
    "--DATABASE_NAME"                = module.glue_crawler.database_name != null ? module.glue_crawler.database_name : "data-lake"
    "--TABLE_NAME"                   = "raw"
    "--OUTPUT_BUCKET_NAME"           = module.s3_processed.bucket_name
    "--OUTPUT_PREFIX"                = "processed"
  }

  glue_version      = "5.0"
  execution_class   = "STANDARD"
  max_retries       = 0
  timeout           = 480
  number_of_workers = 10
  worker_type       = "G.1X"

  execution_property {
    max_concurrent_runs = 1
  }
}

# If you need to import an existing job, uncomment the import block below
# and comment out the resource above, then run: terraform import aws_glue_job.etl_job ETL-datalake
# import {
#   to = aws_glue_job.etl_job
#   id = "ETL-datalake"
# }
