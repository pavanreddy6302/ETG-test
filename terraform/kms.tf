# KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name = "${var.cluster_name}-s3-kms-key"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/${var.cluster_name}-s3-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

# KMS key for RDS encryption
# KMS key for RDS encryption
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption and backups"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        Sid = "Allow RDS Service to Use the Key",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name = "${var.cluster_name}-rds-kms-key"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/${var.cluster_name}-rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}
data "aws_caller_identity" "current" {}
