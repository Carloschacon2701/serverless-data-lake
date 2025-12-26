locals {
  create_object = var.path_to_object_to_upload != null && length(var.path_to_object_to_upload) > 0 ? 1 : 0
  # Use path.root to reference from project root (where jobs/etljob.py is located)
  # Strip leading ./ if present
  clean_path     = var.path_to_object_to_upload != null ? replace(var.path_to_object_to_upload, "./", "") : ""
  path_to_module = var.path_to_object_to_upload != null ? "${path.root}/${local.clean_path}" : ""
}

########################################################
# S3 Bucket
########################################################
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

}

########################################################
# S3 Bucket Notification
########################################################
resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.create_lambda_triger ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

########################################################
# S3 Object Upload
########################################################
resource "aws_s3_object" "object" {
  count      = local.create_object
  bucket     = aws_s3_bucket.bucket.id
  key        = "etljob.py"
  source     = local.path_to_module
  etag       = filemd5(local.path_to_module)
  depends_on = [aws_s3_bucket.bucket]
}
