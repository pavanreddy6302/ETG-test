data "aws_eks_cluster" "cluster1" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster1.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster1.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
    command     = "aws"
  }
}

resource "kubernetes_cluster_role_binding" "admin_user" {
  # Consolidate all dependencies into one depends_on block
  depends_on = [
    aws_eks_access_policy_association.admin_policy_cluster_admin,
    aws_eks_access_entry.cluster_admin_access,
    data.aws_eks_cluster.cluster1
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
    name      = var.cluster_name
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


