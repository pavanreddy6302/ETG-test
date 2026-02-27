# resource "aws_secretsmanager_secret" "rds_credentials" {
#   name = "${var.cluster_name}-rds-credentials"
# }

# resource "aws_secretsmanager_secret_version" "rds_credentials" {
#   secret_id = aws_secretsmanager_secret.rds_credentials.id
#   secret_string = jsonencode({
#     mysql_username    = var.mysql_username
#     mysql_password    = random_password.mysql_password.result
#     postgres_username = var.postgres_username
#     postgres_password = random_password.postgres_password.result
#   })
# }

# resource "random_password" "mysql_password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%^&*()-_=+[]{}<>:?"  # Excluding /, @, ", and space
#   min_special      = 2
#   min_upper        = 2
#   min_lower        = 2
#   min_numeric      = 2
# }

# resource "random_password" "postgres_password" {
#   length  = 16
#   special = true
# }
