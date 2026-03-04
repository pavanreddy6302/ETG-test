# Existing variables - unchanged
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

# Modified - Updated cluster version to supported version for add-ons
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "node_instance_types" {
  description = "List of EC2 instance types for worker nodes"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

variable "ssh_key_name" {
  description = "EC2 key pair name for SSH access (leave empty if not required)"
  type        = string
}

# New variables for add-ons
variable "addon_versions" {
  description = "Versions for EKS add-ons"
  type        = map(string)
  default     = {
    "vpc-cni"             = "v1.15.1-eksbuild.1"
    "kube-proxy"          = "v1.28.1-eksbuild.1"
    "coredns"             = "v1.10.1-eksbuild.2"
    "aws-ebs-csi-driver"  = "v1.25.0-eksbuild.1"
    "pod-identity-agent"  = "v1.0.0-eksbuild.1"
  }
}

variable "addon_service_account_names" {
  description = "Service account names for EKS add-ons"
  type        = map(string)
  default     = {
    "vpc-cni"            = "aws-node"
    "ebs-csi-driver"     = "ebs-csi-controller-sa"
  }
}

# Tags variables
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "test"
    Terraform   = "true"
  }
}
variable "mysql_username" {
  description = "MySQL admin username"
  type        = string
}

variable "postgres_username" {
  description = "PostgreSQL admin username"
  type        = string
}
variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "ssh_public_key" {
  description = "The public key for the EC2 instance"
  type        = string
}

variable "ssh_secret_name" {
  description = "Name for the SSH private key secret in AWS Secrets Manager"
  type        = string
}

variable "crop_bucket" {
  description = "S3 bucket for Crop Images"
  type        = string
}

variable "asset_bucket" {
  description = "S3 bucket for Dspace Assets Images"
  type        = string
}

variable "environment" { type = string }
variable "tags" {
  type = map(string)
}