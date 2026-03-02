# #############################################
# # 1️⃣ EKS Cluster IAM Role
# #############################################
 
# resource "aws_iam_role" "eks_cluster_role" {
#   name = "${var.cluster_name}-eks-cluster-role"
 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = {
#         Service = "eks.amazonaws.com"
#       },
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
 
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#   role       = aws_iam_role.eks_cluster_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }
# resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = aws_iam_role.eks_cluster_role.name
# }
 
# #############################################
# # 2️⃣ EKS Node Group IAM Role
# #############################################
 
# resource "aws_iam_role" "eks_node_role" {
#   name = "${var.cluster_name}-eks-node-role"
 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       },
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
 
# resource "aws_iam_role_policy_attachment" "node_worker_policy" {
#   role       = aws_iam_role.eks_node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }
 
# resource "aws_iam_role_policy_attachment" "node_cni_policy" {
#   role       = aws_iam_role.eks_node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }
 
# resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
#   role       = aws_iam_role.eks_node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }
 

# ############################################
# # 1️⃣ GitHub OIDC Provider (Create Once)
# ############################################
 
# resource "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"
 
#   client_id_list = [
#     "sts.amazonaws.com"
#   ]
 
#   thumbprint_list = [
#     "6938fd4d98bab03faadb97b34396831e3780aea1"
#   ]
# }
 
# ############################################
# # 2️⃣ GitHub Actions IAM Role
# ############################################
 
# resource "aws_iam_role" "github_actions_role" {
#   name = "github-actions-eks-role"
 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.github.arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
#         }
#         StringLike = {
#           "token.actions.githubusercontent.com:sub" = "repo:pavanreddy6302/ETG-test:*"
#         }
#       }
#     }]
#   })
# }
 
# ############################################
# # 3️⃣ Attach Admin Policy (Simple for Now)
# ############################################
 
# resource "aws_iam_role_policy_attachment" "github_admin_access" {
#   role       = aws_iam_role.github_actions_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
 
# ############################################
# # 4️⃣ Give Role Access To EKS Cluster
# ############################################
 
# resource "aws_eks_access_entry" "github_admin" {
#   cluster_name  = var.cluster_name
#   principal_arn = aws_iam_role.github_actions_role.arn
#   type          = "STANDARD"
# }
 
# resource "aws_eks_access_policy_association" "github_admin_policy" {
#   cluster_name  = var.cluster_name
#   principal_arn = aws_iam_role.github_actions_role.arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
 
#   access_scope {
#     type = "cluster"
#   }
# }
 

# resource "aws_eks_access_policy_association" "github_admin_policy1" {
#   cluster_name  = var.cluster_name
#   principal_arn = aws_iam_role.github_actions_role.arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

#   access_scope {
#     type = "cluster"
#   }

#   depends_on = [aws_eks_access_entry.github_admin]
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


resource "aws_eks_access_policy_association" "github_cluster_admin_policy" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.github_actions_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_admin]
}
