
# # IAM Role for ALB Controller
# resource "aws_iam_role" "alb_controller" {
#   name = "${var.cluster_name}-alb-controller"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.eks.arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com"
#         }
#         StringLike = {
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })
# }

# # ALB Controller Policy
# resource "aws_iam_policy" "alb_controller" {
#   name        = "${var.cluster_name}-alb-controller-policy"
#   description = "Policy for AWS Load Balancer Controller"
  
#   policy = file("alb-policy.json")
# }

# # ALB Controller IAM Role Policy Attachment
# resource "aws_iam_role_policy_attachment" "alb_controller" {
#   policy_arn = aws_iam_policy.alb_controller.arn
#   role       = aws_iam_role.alb_controller.name
# }

# # Helm Provider Configuration
# provider "helm" {
#   kubernetes {
#     host                   = aws_eks_cluster.eks_cluster.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name, "--region", var.aws_region]
#       command     = "aws"
#     }
#   }
# }

# # Install ALB Controller via Helm
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.eks_cluster.name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.alb_controller.arn
#   }

#   set {
#     name  = "vpcId"
#     value = aws_vpc.eks_vpc.id
#   }

#   timeout = 600

#   depends_on = [
#     aws_eks_cluster.eks_cluster,
#     aws_iam_role.alb_controller, # Ensure IAM role is created before Helm release
#     aws_iam_policy.alb_controller, # Ensure the policy is attached before Helm release
#     aws_iam_role_policy_attachment.alb_controller # Ensure policy attachment is applied
#   ]
# }
# output "eks_cluster_name" {
#   description = "The name of the EKS cluster"
#   value       = aws_eks_cluster.eks_cluster.name
# }

# output "service_account_name" {
#   description = "The name of the Service Account"
#   value       = helm_release.aws_load_balancer_controller.name
# }




# ########################################
# # AWS provider (example)
# ########################################
# provider "aws" {
#   region = var.aws_region
# }

########################################
# EKS connection data (no resource refs)
########################################
data "aws_eks_cluster" "by_name" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "by_name" {
  name = var.cluster_name
}

########################################
# Kubernetes Provider (token-based)
# NOTE: no load_config_file here
########################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.by_name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.by_name.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.by_name.token
}

########################################
# Helm Provider uses embedded kubernetes
########################################
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.by_name.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.by_name.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.by_name.token
  }
}

########################################
# IAM Role for ALB Controller (IRSA)
########################################
resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("alb-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}

########################################
# Install ALB Controller via Helm
# (Helm provider now has a valid token)
########################################
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  # Optional: pin a chart version compatible with your K8s
  # version    = ">= 1.7.0"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  # If you have the VPC ID as a data source or variable, use that instead of a resource ref:
  # e.g., data "aws_vpc" "selected" { id = var.vpc_id }
  # Or pass var.vpc_id directly.
  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  timeout = 600

  depends_on = [
    aws_iam_role.alb_controller,
    aws_iam_policy.alb_controller,
    aws_iam_role_policy_attachment.alb_controller
  ]
}

########################################
# RBAC: cluster-admin to IAM user
########################################
resource "kubernetes_cluster_role_binding" "admin_user" {
  # keep your EKS Access resources if you use EKS Access Entries/Policies
  depends_on = [
    aws_eks_access_policy_association.admin_policy_cluster_admin,
    aws_eks_access_entry.cluster_admin_access
  ]

  metadata {
    name = "${var.cluster_name}-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = aws_iam_user.cluster_admin.name
    api_group = "rbac.authorization.k8s.io"
  }
}

########################################
# RBAC: cluster-admin for ALB controller SA (optional)
########################################
resource "kubernetes_cluster_role_binding" "alb_controller" {
  metadata {
    name = "alb-controller-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }

  # Ensure the SA exists first (if created by Helm):
  depends_on = [helm_release.aws_load_balancer_controller]
}

########################################
# Outputs
########################################
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.cluster_name
}

output "alb_controller_role_arn" {
  description = "IAM role ARN assumed by the controller (IRSA)"
  value       = aws_iam_role.alb_controller.arn
}