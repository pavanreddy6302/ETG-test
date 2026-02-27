# Security Groups
resource "aws_security_group" "rds" {
  name   = "${var.cluster_name}-rds-sg"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }
}

# MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier        = "${var.cluster_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "hc_db"
  username = var.mysql_username
  password = random_password.mysql_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  skip_final_snapshot = true
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn

  # Enable automated daily backups
  backup_retention_period = 7  # Set the retention period for backups (in days)
  backup_window = "03:00-04:00"  # Specify the preferred backup window in UTC
}

# PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier        = "${var.cluster_name}-postgres"
  engine            = "postgres"
  engine_version    = "13.18"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "dspace"
  username = var.postgres_username
  password = random_password.postgres_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  skip_final_snapshot = true
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn

  # Enable automated daily backups
  backup_retention_period = 7  # Set the retention period for backups (in days)
  backup_window = "03:00-04:00"  # Specify the preferred backup window in UTC
}

# Subnet Group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.cluster_name}-rds-subnet-group"
  subnet_ids = aws_subnet.eks_private[*].id
}
