
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




#############################
# Variables (assumed exist) #
#############################
# variable "aws_region" { type = string }
# variable "cluster_name" { type = string }

########################################
# (Assumption) Existing EKS/VPC blocks #
########################################
# resource "aws_eks_cluster" "eks_cluster" { ... }
# resource "aws_vpc" "eks_vpc" { ... }

########################################
# EKS data sources for Helm connection #
########################################

# Get live EKS connection details (endpoint & CA)
data "aws_eks_cluster" "conn" {
  name = aws_eks_cluster.eks_cluster.name
}

# Get an authentication token for the cluster
data "aws_eks_cluster_auth" "conn" {
  name = aws_eks_cluster.eks_cluster.name
}

########################################
# IAM OIDC provider (assumed exists)   #
########################################
# If you already have this, keep your existing resource and name.
# resource "aws_iam_openid_connect_provider" "eks" { ... }

#############################
# IAM Role for ALB Controller
#############################
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

#############################
# ALB Controller Policy
#############################
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("alb-policy.json")
}

########################################
# ALB Controller IAM Role Policy Attach
########################################
resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}

########################################
# Helm Provider Configuration (no exec)
########################################
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.conn.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.conn.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.conn.token
    load_config_file       = false
  }
}

########################################
# Install ALB Controller via Helm
########################################
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  # (Optional) Pin to a compatible chart version range if you prefer
  # version    = ">= 1.7.0"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster.name
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

  set {
    name  = "vpcId"
    value = aws_vpc.eks_vpc.id
  }

  timeout = 600

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role.alb_controller,
    aws_iam_policy.alb_controller,
    aws_iam_role_policy_attachment.alb_controller
  ]
}

#############################
# Useful Outputs
#############################
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "service_account_name" {
  description = "The name of the Service Account"
  value       = "aws-load-balancer-controller"
}

output "alb_controller_role_arn" {
  description = "IAM role ARN assumed by the controller (IRSA)"
  value       = aws_iam_role.alb_controller.arn
}