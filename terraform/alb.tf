# Helm Provider Configuration
provider "helm" {
  kubernetes  {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
      command     = "aws"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# IAM Role for ALB Controller
resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com"
        }
        StringLike = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

# ALB Controller Policy
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Policy for AWS Load Balancer Controller"
  
  policy = file("alb-policy.json")
}

# ALB Controller IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}



# Install ALB Controller via Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

#   set = [
#     {name  = "clusterName"
#     type = "string"
#     value = var.cluster_name},
#     {name  = "serviceAccount.create"
#         value = "true"},
#     {name  = "serviceAccount.name"
#         value = "aws-load-balancer-controller"
#         type  = "string"},
#         {name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#         value = aws_iam_role.alb_controller.arn},
#     {name  = "serviceAccount.name"
#         value = "vpcId"
#         type  = aws_vpc.eks_vpc.id}]

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set  {
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
    data.aws_eks_cluster.cluster,
    aws_iam_role.alb_controller, # Ensure IAM role is created before Helm release
    aws_iam_policy.alb_controller, # Ensure the policy is attached before Helm release
    aws_iam_role_policy_attachment.alb_controller # Ensure policy attachment is applied
  ]
}
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "service_account_name" {
  description = "The name of the Service Account"
  value       = helm_release.aws_load_balancer_controller.name
}