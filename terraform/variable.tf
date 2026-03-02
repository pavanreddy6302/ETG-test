# Existing variables - unchanged
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "training-vpc-vpc"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Modified - Updated cluster version to supported version for add-ons
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "claimaforge-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"  
}

variable "node_instance_types" {
  description = "List of EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3a.xlarge"]  # Modified from t2.micro as it's too small for EKS workloads
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 5
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 5
}

variable "ssh_key_name" {
  description = "EC2 key pair name for SSH access (leave empty if not required)"
  type        = string
  default     = ""
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
  default     = "api"
}

variable "postgres_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "dspace"
}
# variable "github_org" {
#   description = "GitHub organization name"
#   type        = string
#   default     = "hcl-x"
# }

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "rds-ec2-key"  # Name of your SSH key pair
}

variable "ssh_public_key" {
  description = "The public key for the EC2 instance"
  type        = string
  default     = ""  # Leave empty so it can be provided during Terraform plan/apply or in your `terraform.tfvars`
}

variable "ssh_secret_name" {
  description = "Name for the SSH private key secret in AWS Secrets Manager"
  type        = string
  default     = "rds-ec2-ssh-private-key"
}

variable "crop_bucket" {
  description = "S3 bucket for Crop Images"
  type        = string
  default     = "claimaforge-test-bucket-12345"
}

variable "asset_bucket" {
  description = "S3 bucket for Dspace Assets Images"
  type        = string
  default     = "claimaforge-test-bucket-54321"
}


# Principals (usually SSO roles) allowed to AssumeRole into the EKS Admin Role
variable "trusted_admin_principals" {
  description = "IAM Role ARNs allowed to assume the EKS admin role"
  type        = list(string)
  default     = [  ]
}

# variable "private_subnet_ids" {
#   type = list(string)
  
# }

# variable "public_subnet_ids" {
#   type = list(string)
  
# }

variable "github_org" {
  type = string
  default = "pavanreddy6302"
}

variable "github_repo" {
  type = string
  default = "ETG-test"
}