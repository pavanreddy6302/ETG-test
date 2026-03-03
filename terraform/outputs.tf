# outputs.tf
output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_credentials_secret_arn" {
  value = aws_secretsmanager_secret.rds_credentials.arn
}

# Data source to retrieve credentials
data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.rds_connectivity.public_ip
}

output "ec2_instance_ssh_key" {
  description = "SSH private key used for EC2 access"
  value       = aws_key_pair.generated_ec2_keypair.key_name
}

############################################################
# 1) Output the ARN of the SSH Key secret
#    (Private Key stored in AWS Secrets Manager)
############################################################
output "ec2_ssh_secret_arn" {
  description = "ARN of the secret holding the EC2 SSH private key"
  value       = aws_secretsmanager_secret.ec2_ssh_key.arn
}

output "admin_user_arn" {
  value = aws_iam_user.cluster_admin.arn
}



