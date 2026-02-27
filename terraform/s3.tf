# resource "aws_s3_bucket" "test_bucket" {
#   bucket = var.crop_bucket
#   tags = {
#     Name        = "Test S3 Bucket"
#     Environment = "Test"
#   }
# }
# resource "aws_s3_bucket_server_side_encryption_configuration" "test_bucket" {
#   bucket = aws_s3_bucket.test_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.s3_key.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket" "test_bucket1" {
#   bucket = var.asset_bucket
#   tags = {
#     Name        = "Test S3 Bucket"
#     Environment = "Test"
#   }
# }
