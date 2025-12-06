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
    filter_prefix       = "/raw"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
