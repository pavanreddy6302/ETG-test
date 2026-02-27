# ##############################
# # OIDC Provider Configuration
# ##############################

# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }

# ##############################
# # GitHub OIDC provider
# ##############################
# resource "aws_iam_openid_connect_provider" "github" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
#   lifecycle {
#     ignore_changes = [thumbprint_list]
# }
# }
# ##############################
# # GitHub Actions role with trust relationship
# ##############################

# resource "aws_iam_role" "github_actions" {
#   name = "${var.cluster_name}-github-actions"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "eks.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       },
#       {
#         Effect = "Allow",
#         Principal = {
#           AWS = aws_iam_user.cluster_admin.arn,
#           Federated = aws_iam_openid_connect_provider.github.arn
#         },
#         Action = [
#           "sts:AssumeRoleWithWebIdentity",
#           "sts:AssumeRole"
#         ],
#         Condition = {
#           StringEquals = {
#             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
#           },
#           StringLike = {
#             "token.actions.githubusercontent.com:sub": "repo:${var.github_org}/*"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "github_eks_admin" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }

# ##############################
# # IAM Roles for Add-ons
# ##############################

# # IAM Role for EBS CSI Driver
# resource "aws_iam_role" "ebs_csi_driver" {
#   name = "${var.cluster_name}-ebs-csi-driver"

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
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com",
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#         }
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# # IAM Role for VPC CNI
# resource "aws_iam_role" "vpc_cni" {
#   name = "${var.cluster_name}-vpc-cni"

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
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com",
#           "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-node"
#         }
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "vpc_cni" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.vpc_cni.name
# }

# ##############################
# # EKS Add-ons
# ##############################

# # kube-proxy Add-on
# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name      = aws_eks_cluster.eks_cluster.name
#   addon_name        = "kube-proxy"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   depends_on        = [aws_eks_node_group.node_group]
# }

# # Amazon VPC CNI Add-on
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name             = aws_eks_cluster.eks_cluster.name
#   addon_name              = "vpc-cni"
#   service_account_role_arn = aws_iam_role.vpc_cni.arn
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   depends_on              = [aws_eks_node_group.node_group]
# }

# # Amazon EBS CSI Driver Add-on
# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name             = aws_eks_cluster.eks_cluster.name
#   addon_name              = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   depends_on              = [aws_eks_node_group.node_group]
# }

# # Amazon EKS Pod Identity Agent Add-on
# resource "aws_eks_addon" "pod_identity_agent" {
#   cluster_name      = aws_eks_cluster.eks_cluster.name
#   addon_name        = "eks-pod-identity-agent"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   depends_on        = [aws_eks_node_group.node_group]
# }

# # CoreDNS Add-on
# resource "aws_eks_addon" "coredns" {
#   cluster_name      = aws_eks_cluster.eks_cluster.name
#   addon_name        = "coredns"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   depends_on        = [aws_eks_node_group.node_group]
# }
