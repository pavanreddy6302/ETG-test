
data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
    depends_on = [
  aws_eks_cluster.eks_cluster
]
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
 
# Grants cluster-admin permissions to that role
resource "aws_eks_access_policy_association" "github_actions_cluster_admin" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::222634374835:role/claimaforge-cluster-github-actions"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
 
  access_scope {
    type = "cluster"
  }
 
}
 

resource "kubernetes_cluster_role_binding" "admin_user" {
  # Consolidate all dependencies into one depends_on block
  depends_on = [
    aws_eks_access_policy_association.admin_policy_cluster_admin,
    aws_eks_access_entry.cluster_admin_access,
    data.aws_eks_cluster.eks_cluster
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
}

