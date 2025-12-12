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

    etl_job_succeeded = {}
  }
}

import {
  to = aws_glue_job.this
  id = "ETL-datalake"
}
