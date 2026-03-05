# ##############################
# # VPC and Networking Resources
# ##############################

# resource "aws_vpc" "eks_vpc" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = var.vpc_name
#   }
# }

# resource "aws_subnet" "eks_public" {
#   count             = length(var.public_subnet_cidrs)
#   vpc_id            = aws_vpc.eks_vpc.id
#   cidr_block        = var.public_subnet_cidrs[count.index]
#   availability_zone = var.availability_zones[count.index]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "${var.vpc_name}-public-${count.index}"
#     "kubernetes.io/role/elb" = "1"
#     "kubernetes.io/role/${var.cluster_name}" = "shared"
#   }
# }

# resource "aws_subnet" "eks_private" {
#   count             = length(var.private_subnet_cidrs)
#   vpc_id            = aws_vpc.eks_vpc.id
#   cidr_block        = var.private_subnet_cidrs[count.index]
#   availability_zone = var.availability_zones[count.index]
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "${var.vpc_name}-private-${count.index}"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/role/${var.cluster_name}" = "shared"
#   }
# }

# resource "aws_internet_gateway" "eks_igw" {
#   vpc_id = aws_vpc.eks_vpc.id

#   tags = {
#     Name = "${var.vpc_name}-igw"
#   }
# }

# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# resource "aws_nat_gateway" "eks_nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.eks_public[0].id

#   tags = {
#     Name = "${var.vpc_name}-nat"
#   }
# }

# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.eks_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.eks_igw.id
#   }

#   tags = {
#     Name = "${var.vpc_name}-public-rt"
#   }
# }

# resource "aws_route_table_association" "public_assoc" {
#   count          = length(aws_subnet.eks_public)
#   subnet_id      = aws_subnet.eks_public[count.index].id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.eks_vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.eks_nat.id
#   }

#   tags = {
#     Name = "${var.vpc_name}-private-rt"
#   }
# }

# resource "aws_route_table_association" "private_assoc" {
#   count          = length(aws_subnet.eks_private)
#   subnet_id      = aws_subnet.eks_private[count.index].id
#   route_table_id = aws_route_table.private_rt.id
# }
