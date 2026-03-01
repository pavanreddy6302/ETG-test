##############################
# IAM Roles and Policies for EKS
##############################
## EKS Cluster Role
data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

## EKS Node Group Role
data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

##############################
# IAM Users for Cluster Access
##############################

# Cluster admin user
# resource "aws_iam_user" "cluster_admin" {
#   name = "${var.cluster_name}-admin"
# }

# resource "aws_iam_access_key" "cluster_admin" {
#   user = aws_iam_user.cluster_admin.name
# }

# # Store credentials
# resource "aws_secretsmanager_secret" "user_credentials" {
#   name = "${var.cluster_name}-admin-credentials"
# }

# resource "aws_secretsmanager_secret_version" "user_credentials" {
#   secret_id = aws_secretsmanager_secret.user_credentials.id
#   secret_string = jsonencode({
#     access_key = aws_iam_access_key.cluster_admin.id
#     secret_key = aws_iam_access_key.cluster_admin.secret
#   })
# }

# Reference for Rajat Kantjha
#data "aws_iam_user" "rajat_kantjha" {
#  user_name = "rajat.kantjha@hcltech.com"
#}

# Reference existing IAM User for sohail.quazi@hcl.com
# data "aws_iam_user" "sohail_quazi" {
#   user_name = "sohail.quazi@hcl.com"
# }

# Create a second IAM user (replace with actual name if needed)
#resource "aws_iam_user" "second_user" {
#  name = "second-eks-user"
#}

# GitHub Actions role - creating the role, not referencing it
resource "aws_iam_role" "github_actions_role" {
  name = "claimaforge-cluster-github-actions"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"  # Update this with the appropriate principal for GitHub Actions
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

##############################
# IAM Policies
##############################

# Admin policy for EKS access
# resource "aws_iam_policy" "eks_admin" {
#   name        = "${var.cluster_name}-eks-admin-policy"
#   description = "Admin access to EKS cluster and related resources"
  
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "eks:*",
#           "ec2:DescribeInstances",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs",
#           "s3:*",
#           "rds:*",
#           "kms:Decrypt",
#           "kms:DescribeKey"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach policy to users
# resource "aws_iam_user_policy_attachment" "user_eks_admin" {
#   user       = aws_iam_user.cluster_admin.name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }

# # Attach the policy to the GitHub Actions role
# resource "aws_iam_role_policy_attachment" "github_actions_eks_admin" {
#   role       = aws_iam_role.github_actions_role.name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }

# Attach eks-admin policy to Rajat
#resource "aws_iam_user_policy_attachment" "rajat_eks_admin" {
#  user       = data.aws_iam_user.rajat_kantjha.user_name
#  policy_arn = aws_iam_policy.eks_admin.arn
#}

# resource "aws_iam_user_policy_attachment" "sohail_eks_admin" {
#   user       = data.aws_iam_user.sohail_quazi.user_name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }

#add users if you want to enable admin access to the eks cluster
#resource "aws_iam_user_policy_attachment" "second_user_eks_admin" {
#  user       = aws_iam_user.second_user.name
#  policy_arn = aws_iam_policy.eks_admin.arn
#}

##############################
# EKS Access Entries
##############################

# Access entry for the cluster admin user
# resource "aws_eks_access_entry" "cluster_admin_access" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = aws_iam_user.cluster_admin.arn
#   type          = "STANDARD"
  
#   # Use "masters" as a valid group name
#   kubernetes_groups = ["masters"]
# }

# Access entry for rajat.kantjha@hcltech.com
#resource "aws_eks_access_entry" "rajat_kantjha_access" {
#  cluster_name  = aws_eks_cluster.eks_cluster.name
#  principal_arn = data.aws_iam_user.rajat_kantjha.arn
#  type          = "STANDARD"
#  
#  # Use "masters" as a valid group name
#  kubernetes_groups = ["masters"]
#}

# Access entry for sohail.quazi@hcl.com
# resource "aws_eks_access_entry" "sohail_quazi_access" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = data.aws_iam_user.sohail_quazi.arn
#   type          = "STANDARD"
  
#   # Use "masters" as a valid group name
#   kubernetes_groups = ["masters"]
# }

# Access entry for the second user
#resource "aws_eks_access_entry" "second_user_access" {
#  cluster_name  = aws_eks_cluster.eks_cluster.name
#  principal_arn = aws_iam_user.second_user.arn
#  type          = "STANDARD"
#  
  # Use "masters" as a valid group name
#  kubernetes_groups = ["masters"]
#}

# Access entry for the GitHub Actions role - using resource reference instead of data reference
resource "aws_eks_access_entry" "github_actions_role_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.github_actions_role.arn
  type          = "STANDARD"
  
  # Use "masters" as a valid group name
  kubernetes_groups = ["masters"]
}

##############################
# EKS Access Policy for Admin Access
##############################

# This grants cluster-admin permissions to all users and roles
# resource "aws_eks_access_policy_association" "admin_policy_cluster_admin" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = aws_iam_user.cluster_admin.arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
#   access_scope {
#     type = "cluster"
#   }
  
#   depends_on = [aws_eks_access_entry.cluster_admin_access]
# }

# EKS Access Policy for Rajat Kantjha
#resource "aws_eks_access_policy_association" "admin_policy_rajat" {
#  cluster_name  = aws_eks_cluster.eks_cluster.name
#  principal_arn = data.aws_iam_user.rajat_kantjha.arn
#  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#  
#  access_scope {
#    type = "cluster"
#  }
#  
#  depends_on = [aws_eks_access_entry.rajat_kantjha_access]
#}

# resource "aws_eks_access_policy_association" "admin_policy_sohail" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = data.aws_iam_user.sohail_quazi.arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
#   access_scope {
#     type = "cluster"
#   }
  
#   depends_on = [aws_eks_access_entry.sohail_quazi_access]
# }

#resource "aws_eks_access_policy_association" "admin_policy_second_user" {
#  cluster_name  = aws_eks_cluster.eks_cluster.name
#  principal_arn = aws_iam_user.second_user.arn
#  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#  
#  access_scope {
#    type = "cluster"
#  }
  
#  depends_on = [aws_eks_access_entry.second_user_access]
#}

# GitHub Actions role policy association - also updated to use resource reference
resource "aws_eks_access_policy_association" "admin_policy_github_actions" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.github_actions_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
  access_scope {
    type = "cluster"
  }
  
  depends_on = [aws_eks_access_entry.github_actions_role_access]
}


##############################
# IAM Roles and Policies for EKS
##############################

## ===========================
## EKS Cluster Role
## ===========================
data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
  #tags               = try(var.common_tags, null)
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Optional for many Linux worker clusters; keep only if you need it
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

## ===========================
## EKS Node (Worker) Role
## ===========================
data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
  #tags               = try(var.common_tags, null)
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

##############################
# GitHub Actions Role (CI) — keep as EC2-trusted if you use self-hosted EC2 runners
# If you use GitHub-hosted runners, switch this to OIDC trust later.
##############################
resource "aws_iam_role" "github_actions_role" {
  name = "claimaforge-cluster-github-actions"

  # CURRENTLY: EC2 trust (self-hosted runners on EC2)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })

  #tags = try(var.common_tags, null)
}

##############################
# EKS Admin Role (Role-based human admin via SSO/assumable roles)
##############################
data "aws_iam_policy_document" "eks_admin_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.trusted_admin_principals
    }
    # Optional (recommended for human operators):
    # condition {
    #   test     = "Bool"
    #   variable = "aws:MultiFactorAuthPresent"
    #   values   = ["true"]
    # }
  }
}

resource "aws_iam_role" "eks_admin_role" {
  name               = "${var.cluster_name}-eks-admin-role"
  assume_role_policy = data.aws_iam_policy_document.eks_admin_role_trust.json
  #tags               = try(var.common_tags, null)
}

##############################
# EKS Access Entries
##############################

# GitHub Actions role access entry (no legacy K8s groups; rely on Access Policies)
resource "aws_eks_access_entry" "github_actions_role_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.github_actions_role.arn
  type          = "STANDARD"
}

# Admin role access entry (registers the admin role with the cluster)
resource "aws_eks_access_entry" "eks_admin_role_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.eks_admin_role.arn
  type          = "STANDARD"
}

##############################
# EKS Access Policy Associations (grant permissions)
##############################

# CI role — currently cluster-admin (adjust to least-privilege later if desired)
resource "aws_eks_access_policy_association" "admin_policy_github_actions" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.github_actions_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_actions_role_access]
}

# Human Admin role — cluster-admin via AWS-managed policy (modern approach)
resource "aws_eks_access_policy_association" "admin_policy_eks_admin_role" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.eks_admin_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.eks_admin_role_access]
}