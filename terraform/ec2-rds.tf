

# ############################################################
# # 1) Generate a new SSH private key with Terraform
# ############################################################
# resource "tls_private_key" "ec2_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# ############################################################
# # 2) Register this public key in AWS as a Key Pair
# ############################################################
# resource "aws_key_pair" "generated_ec2_keypair" {
#   key_name   = "generated-ec2-keypair"
#   public_key = tls_private_key.ec2_key.public_key_openssh
# }

# ############################################################
# # 3) Store the private key in AWS Secrets Manager
# ############################################################
# # a) Create a secret
# resource "aws_secretsmanager_secret" "ec2_ssh_key" {
#   name        = var.ssh_secret_name
#   description = "SSH private key for EC2 instance"
# }

# # b) Store the secret value (the private key PEM)
# resource "aws_secretsmanager_secret_version" "ec2_ssh_key_version" {
#   secret_id     = aws_secretsmanager_secret.ec2_ssh_key.id
#   secret_string = tls_private_key.ec2_key.private_key_pem
# }

# ############################################################
# # 4) Security Group for EC2
# ############################################################
# resource "aws_security_group" "ec2_sg" {
#   name        = "${var.cluster_name}-ec2-sg"
#   description = "SG for EC2: SSH inbound"
#   vpc_id      = aws_vpc.eks_vpc.id  # from vpc.tf

#   # Allow SSH from anywhere (0.0.0.0/0) - restrict for production
#   ingress {
#     description = "SSH Access"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Egress: allow all outbound
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.cluster_name}-ec2-sg"
#   }
# }

# ############################################################
# # 5) Modify the existing RDS Security Group to allow MySQL
# #    & Postgres inbound from EC2 SG
# ############################################################
# # MySQL (port 3306)
# resource "aws_security_group_rule" "allow_mysql_from_ec2" {
#   type                     = "ingress"
#   from_port                = 3306
#   to_port                  = 3306
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.rds.id
#   source_security_group_id = aws_security_group.ec2_sg.id
# }

# # Postgres (port 5432)
# resource "aws_security_group_rule" "allow_postgres_from_ec2" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.rds.id
#   source_security_group_id = aws_security_group.ec2_sg.id
# }

# ############################################################
# # 6) Create an EC2 instance with a public IP
# #    referencing the new Key Pair
# ############################################################
# resource "aws_instance" "rds_connectivity" {
#   ami                    = "ami-0d682f26195e9ec0f"   # Example Ubuntu AMI in ap-south-1
#   instance_type          = "t2.micro"
#   subnet_id              = element(aws_subnet.eks_public[*].id, 0)  # place in public subnet
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]
#   key_name               = aws_key_pair.generated_ec2_keypair.key_name
#   associate_public_ip_address = true

#   # Example user data to install MySQL & Postgres clients
#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update -y
#               apt-get install -y mysql-client postgresql-client
#               EOF

#   tags = {
#     Name = "${var.cluster_name}-ec2-instance"
#   }
# }
