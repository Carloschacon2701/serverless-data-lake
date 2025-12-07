module "s3" {
  source               = "./modules/s3"
  project_name         = "data-lake-serverless"
  bucket_name          = "data-lake-serverless"
  create_lambda_triger = true
  lambda_function_arn  = module.lambda.function_arn

}

module "s3_processed" {
  source       = "./modules/s3"
  project_name = "data-lake-serverless"
  bucket_name  = "data-lake-serverless-processed"
}

module "lambda" {
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
import {
  to = aws_glue_crawler.crawler
  id = "crawler-datalake"
}

resource "aws_glue_crawler" "crawler" {
  database_name = "data-lake"
  name          = "crawler-datalake"
  role          = "service-role/AWSGlueServiceRole-lake"

  s3_target {
    path = "s3://etl-data-lake-foundation/raw"
  }
}
