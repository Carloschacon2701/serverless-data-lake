########################################################
# Lambda Permission
########################################################
resource "aws_lambda_permission" "allow_bucket" {
  count         = var.create_lambda_triger ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}
