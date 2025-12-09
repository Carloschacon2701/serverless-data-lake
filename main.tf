module "s3" {
  source               = "./modules/s3"
  project_name         = "data-lake-serverless"
  bucket_name          = "data-lake-serverless"
  create_lambda_triger = true
  lambda_function_arn  = module.s3_lambda_trigger.function_arn

}

module "s3_processed" {
  source       = "./modules/s3"
  project_name = "data-lake-serverless"
  bucket_name  = "data-lake-serverless-processed"
}

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

module "glue_crawler" {
  source         = "./modules/glue"
  project_name   = "data-lake-serverless"
  database_name  = "data-lake"
  crawler_name   = "crawler-datalake"
  s3_target_path = "s3://${module.s3.bucket_name}/raw"
}
