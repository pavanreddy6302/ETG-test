##############################
# EKS Cluster and Managed Node Group
##############################

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = concat(aws_subnet.eks_private[*].id, aws_subnet.eks_public[*].id)
    #subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
  }

  version = var.cluster_version

  depends_on = [
    #aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_private[*].id
  #subnet_ids = var.private_subnet_ids
  version         = var.cluster_version

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  labels = {
     "clusterType" = "solrcloud"
     "clustertype" = "zookeeper"
  }

  instance_types = var.node_instance_types

  dynamic "remote_access" {
    for_each = var.ssh_key_name != "" ? [1] : []
    content {
      ec2_ssh_key = var.ssh_key_name
    }
  }

  depends_on = [
    #aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
  ]
}

