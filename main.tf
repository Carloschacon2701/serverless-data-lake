########################################################
# S3 Bucket Raw
########################################################
module "s3" {
  source               = "./modules/s3"
  project_name         = var.project_name
  bucket_name          = var.project_name
  create_lambda_triger = true
  lambda_function_arn  = module.s3_lambda_trigger.function_arn
  service_to_access_bucket = [{
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.project_name}/raw/*", "arn:aws:s3:::${var.project_name}"]
    principal = module.glue_crawler.glue_role_arn
  }]
}

# ########################################################
# # S3 Bucket Processed
# ########################################################
# module "s3_processed" {
#   source       = "./modules/s3"
#   project_name = "data-lake-serverless"
#   bucket_name  = "data-lake-serverless-processed"
# }

########################################################
# S3 for scripts
########################################################
module "s3_scripts" {
  source                   = "./modules/s3"
  project_name             = var.project_name
  bucket_name              = "${var.project_name}-scripts"
  path_to_object_to_upload = "./jobs/etljob.py"
}

########################################################
# S3 Lambda Trigger
########################################################
module "s3_lambda_trigger" {
  source         = "./modules/lambda"
  project_name   = var.project_name
  function_name  = "data-lake-serverless"
  handler        = "index.handler"
  runtime        = "nodejs20.x"
  code_path      = "./lambda/startCrawler/index.mjs"
  error_handling = true
  environment_variables = [
    {
      name  = "CRAWLER_NAME"
      value = module.glue_crawler.crawler_name
    }
  ]

  role_attributes = [
    {
      actions   = ["glue:StartCrawler"]
      effect    = "Allow"
      resources = [module.glue_crawler.crawler_arn]
    }
  ]

}

########################################################
# Glue Crawler
########################################################
module "glue_crawler" {
  source         = "./modules/glue"
  project_name   = var.project_name
  database_name  = var.project_name
  crawler_name   = "crawler-datalake-serverless"
  s3_target_path = "s3://${var.project_name}/raw"
  create_crawler = true
  role_attributes = [{
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.project_name}/raw/*"]
  }]
}

########################################################
# Glue Crawler Succeeded Lambda
########################################################
module "glue_crawler_succeeded_lambda" {
  source        = "./modules/lambda"
  project_name  = var.project_name
  function_name = "glue-crawler-succeeded"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  code_path     = "./lambda/startJob/index.mjs"
  environment_variables = [
    {
      name  = "JOB_NAME"
      value = module.etl_job.job_name
    }
  ]
  role_attributes = [{
    actions   = ["glue:StartJobRun", "glue:GetJobRun"]
    effect    = "Allow"
    resources = [module.etl_job.job_arn]
  }]
}

########################################################
# SNS Topic
########################################################
module "sns_topic" {
  source = "terraform-aws-modules/sns/aws"

  name = var.project_name

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

  # bus_name    = var.project_name
  create_bus  = false
  create_role = true
  role_name   = "${var.project_name}-eventbridge-role"

  # attach_policy        = true
  attach_lambda_policy = true
  lambda_target_arns   = [module.glue_crawler_succeeded_lambda.function_arn]

  attach_sns_policy = true
  sns_target_arns   = [module.sns_topic.topic_arn]

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
          "jobName" = [module.etl_job.job_name]
          "state"   = ["SUCCEEDED"]
        }
      })
      enabled = true
    }
  }

  targets = {
    glue_crawler_succeeded = [
      {
        name            = "glue-crawler-succeeded-lambda"
        arn             = module.glue_crawler_succeeded_lambda.function_arn
        attach_role_arn = true
      }
    ]

    etl_job_succeeded = [
      {
        name            = "etl-job-succeeded-sns"
        arn             = module.sns_topic.topic_arn
        attach_role_arn = true
      }
    ]
  }
}


########################################################
# Glue ETL Job
########################################################
module "etl_job" {
  source                 = "./modules/glue"
  project_name           = var.project_name
  etl_database_name      = module.glue_crawler.database_name
  etl_table_name         = "raw"
  etl_output_bucket_name = module.s3.bucket_name
  etl_output_prefix      = "processed"
  job_name               = "etl-datalake"
  s3_scripts_bucket_name = module.s3_scripts.bucket_name
  create_job             = true
  role_attributes = [{
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.project_name}", "arn:aws:s3:::${var.project_name}/processed/*", "arn:aws:s3:::${var.project_name}/raw/*", "arn:aws:s3:::${module.s3_scripts.bucket_name}", "arn:aws:s3:::${module.s3_scripts.bucket_name}/*"]
  }]
}

########################################################
# Athena Module
########################################################
module "athena" {
  source         = "./modules/athena"
  project_name   = var.project_name
  workgroup_name = var.project_name
  database_name  = module.glue_crawler.database_name
  bucket_name    = "${module.s3.bucket_name}/processed"
  columns = [
    {
      name = "tpep_dropoff_datetime"
      type = "string"
    },
    {
      name = "trip_distance"
      type = "double"
    },
    {
      name = "fare_amount"
      type = "double"
    },
    {
      name = "tpep_pickup_datetime"
      type = "string"
    },
    {
      name = "tolls_amount"
      type = "double"
    },
    {
      name = "tip_amount"
      type = "double"
    },
    {
      name = "passenger_count"
      type = "int"
    },
    {
      name = "total_amount"
      type = "double"
    },
    {
      name = "trip_duration_minutes"
      type = "double"
    },
    {
      name = "trip_category"
      type = "string"
    },
    {
      name = "tip_percentage"
      type = "double"
    }
  ]
}
