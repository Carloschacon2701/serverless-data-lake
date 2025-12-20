locals {
  create_bucket_policy = length(var.service_to_access_bucket) > 0
}

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


resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = local.create_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for attr in var.service_to_access_bucket : {
        Action   = attr.actions
        Effect   = attr.effect
        Resource = attr.resources
        Principal = {
          AWS = attr.principal
        }
      }
    ]
  })
}
