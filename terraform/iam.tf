# ##############################
# # IAM Roles and Policies for EKS
# ##############################
# ## EKS Cluster Role
# data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "eks_cluster_role" {
#   name               = "${var.cluster_name}-cluster-role"
#   assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_cluster_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = aws_iam_role.eks_cluster_role.name
# }

# ## EKS Node Group Role
# data "aws_iam_policy_document" "eks_node_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "eks_node_role" {
#   name               = "${var.cluster_name}-node-role"
#   assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_node_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_node_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_node_role.name
# }

# ##############################
# # IAM Users for Cluster Access
# ##############################

# # Cluster admin user
# # resource "aws_iam_user" "cluster_admin" {
# #   name = "${var.cluster_name}-admin"
# # }

# # resource "aws_iam_access_key" "cluster_admin" {
# #   user = aws_iam_user.cluster_admin.name
# # }

# # # Store credentials
# # resource "aws_secretsmanager_secret" "user_credentials" {
# #   name = "${var.cluster_name}-admin-credentials"
# # }

# # resource "aws_secretsmanager_secret_version" "user_credentials" {
# #   secret_id = aws_secretsmanager_secret.user_credentials.id
# #   secret_string = jsonencode({
# #     access_key = aws_iam_access_key.cluster_admin.id
# #     secret_key = aws_iam_access_key.cluster_admin.secret
# #   })
# # }

# # Reference for Rajat Kantjha
# #data "aws_iam_user" "rajat_kantjha" {
# #  user_name = "rajat.kantjha@hcltech.com"
# #}

# # Reference existing IAM User for sohail.quazi@hcl.com
# # data "aws_iam_user" "sohail_quazi" {
# #   user_name = "sohail.quazi@hcl.com"
# # }

# # Create a second IAM user (replace with actual name if needed)
# #resource "aws_iam_user" "second_user" {
# #  name = "second-eks-user"
# #}

# # GitHub Actions role - creating the role, not referencing it
# resource "aws_iam_role" "github_actions_role" {
#   name = "claimaforge-cluster-github-actions"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"  # Update this with the appropriate principal for GitHub Actions
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# ##############################
# # IAM Policies
# ##############################

# # Admin policy for EKS access
# # resource "aws_iam_policy" "eks_admin" {
# #   name        = "${var.cluster_name}-eks-admin-policy"
# #   description = "Admin access to EKS cluster and related resources"
  
# #   policy = jsonencode({
# #     Version = "2012-10-17",
# #     Statement = [
# #       {
# #         Effect = "Allow",
# #         Action = [
# #           "eks:*",
# #           "ec2:DescribeInstances",
# #           "ec2:DescribeNetworkInterfaces",
# #           "ec2:DescribeSecurityGroups",
# #           "ec2:DescribeSubnets",
# #           "ec2:DescribeVpcs",
# #           "s3:*",
# #           "rds:*",
# #           "kms:Decrypt",
# #           "kms:DescribeKey"
# #         ],
# #         Resource = "*"
# #       }
# #     ]
# #   })
# # }

# # # Attach policy to users
# # resource "aws_iam_user_policy_attachment" "user_eks_admin" {
# #   user       = aws_iam_user.cluster_admin.name
# #   policy_arn = aws_iam_policy.eks_admin.arn
# # }

# # # Attach the policy to the GitHub Actions role
# # resource "aws_iam_role_policy_attachment" "github_actions_eks_admin" {
# #   role       = aws_iam_role.github_actions_role.name
# #   policy_arn = aws_iam_policy.eks_admin.arn
# # }

# # Attach eks-admin policy to Rajat
# #resource "aws_iam_user_policy_attachment" "rajat_eks_admin" {
# #  user       = data.aws_iam_user.rajat_kantjha.user_name
# #  policy_arn = aws_iam_policy.eks_admin.arn
# #}

# # resource "aws_iam_user_policy_attachment" "sohail_eks_admin" {
# #   user       = data.aws_iam_user.sohail_quazi.user_name
# #   policy_arn = aws_iam_policy.eks_admin.arn
# # }

# #add users if you want to enable admin access to the eks cluster
# #resource "aws_iam_user_policy_attachment" "second_user_eks_admin" {
# #  user       = aws_iam_user.second_user.name
# #  policy_arn = aws_iam_policy.eks_admin.arn
# #}

# ##############################
# # EKS Access Entries
# ##############################

# # Access entry for the cluster admin user
# # resource "aws_eks_access_entry" "cluster_admin_access" {
# #   cluster_name  = aws_eks_cluster.eks_cluster.name
# #   principal_arn = aws_iam_user.cluster_admin.arn
# #   type          = "STANDARD"
  
# #   # Use "masters" as a valid group name
# #   kubernetes_groups = ["masters"]
# # }

# # Access entry for rajat.kantjha@hcltech.com
# #resource "aws_eks_access_entry" "rajat_kantjha_access" {
# #  cluster_name  = aws_eks_cluster.eks_cluster.name
# #  principal_arn = data.aws_iam_user.rajat_kantjha.arn
# #  type          = "STANDARD"
# #  
# #  # Use "masters" as a valid group name
# #  kubernetes_groups = ["masters"]
# #}

# # Access entry for sohail.quazi@hcl.com
# # resource "aws_eks_access_entry" "sohail_quazi_access" {
# #   cluster_name  = aws_eks_cluster.eks_cluster.name
# #   principal_arn = data.aws_iam_user.sohail_quazi.arn
# #   type          = "STANDARD"
  
# #   # Use "masters" as a valid group name
# #   kubernetes_groups = ["masters"]
# # }

# # Access entry for the second user
# #resource "aws_eks_access_entry" "second_user_access" {
# #  cluster_name  = aws_eks_cluster.eks_cluster.name
# #  principal_arn = aws_iam_user.second_user.arn
# #  type          = "STANDARD"
# #  
#   # Use "masters" as a valid group name
# #  kubernetes_groups = ["masters"]
# #}

# # Access entry for the GitHub Actions role - using resource reference instead of data reference
# resource "aws_eks_access_entry" "github_actions_role_access" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = aws_iam_role.github_actions_role.arn
#   type          = "STANDARD"
  
#   # Use "masters" as a valid group name
#   kubernetes_groups = ["masters"]
# }

# ##############################
# # EKS Access Policy for Admin Access
# ##############################

# # This grants cluster-admin permissions to all users and roles
# # resource "aws_eks_access_policy_association" "admin_policy_cluster_admin" {
# #   cluster_name  = aws_eks_cluster.eks_cluster.name
# #   principal_arn = aws_iam_user.cluster_admin.arn
# #   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
# #   access_scope {
# #     type = "cluster"
# #   }
  
# #   depends_on = [aws_eks_access_entry.cluster_admin_access]
# # }

# # EKS Access Policy for Rajat Kantjha
# #resource "aws_eks_access_policy_association" "admin_policy_rajat" {
# #  cluster_name  = aws_eks_cluster.eks_cluster.name
# #  principal_arn = data.aws_iam_user.rajat_kantjha.arn
# #  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# #  
# #  access_scope {
# #    type = "cluster"
# #  }
# #  
# #  depends_on = [aws_eks_access_entry.rajat_kantjha_access]
# #}

# # resource "aws_eks_access_policy_association" "admin_policy_sohail" {
# #   cluster_name  = aws_eks_cluster.eks_cluster.name
# #   principal_arn = data.aws_iam_user.sohail_quazi.arn
# #   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
# #   access_scope {
# #     type = "cluster"
# #   }
  
# #   depends_on = [aws_eks_access_entry.sohail_quazi_access]
# # }

# #resource "aws_eks_access_policy_association" "admin_policy_second_user" {
# #  cluster_name  = aws_eks_cluster.eks_cluster.name
# #  principal_arn = aws_iam_user.second_user.arn
# #  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# #  
# #  access_scope {
# #    type = "cluster"
# #  }
  
# #  depends_on = [aws_eks_access_entry.second_user_access]
# #}

# # GitHub Actions role policy association - also updated to use resource reference
# resource "aws_eks_access_policy_association" "admin_policy_github_actions" {
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = aws_iam_role.github_actions_role.arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
#   access_scope {
#     type = "cluster"
#   }
  
#   depends_on = [aws_eks_access_entry.github_actions_role_access]
# }




#############################################
# 1) EKS Cluster IAM Role
#############################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

#############################################
# 2) EKS Node Group IAM Role
#############################################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional: SSM access to nodes
resource "aws_iam_role_policy_attachment" "node_ssm_core" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#############################################
# 3) GitHub OIDC Provider (Create once per account)
#############################################
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

#############################################
# 4) GitHub Actions IAM Role (OIDC)
#############################################
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:pavanreddy6302/ETG-test:*"
        }
      }
    }]
  })
}

# Bootstrap-wide permissions for now (replace with least-privilege later)
resource "aws_iam_role_policy_attachment" "github_admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#############################################
# 5) Give the GH role access to Kubernetes on this EKS cluster
#############################################

# Access Entry (authentication binding)
resource "aws_eks_access_entry" "github_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.github_actions_role.arn
  type          = "STANDARD"

  # Ensure the cluster exists first if created in same stack
  # depends_on = [aws_eks_cluster.eks_cluster]
}

# ---- Choose ONE of the following associations ----
# A) Full cluster admin (common for CI)
resource "aws_eks_access_policy_association" "github_cluster_admin_policy" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.github_actions_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_admin]
}

# B) (Alternative) Admin (slightly less than full cluster admin)
resource "aws_eks_access_policy_association" "github_admin_policy" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.github_actions_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_admin]
}

