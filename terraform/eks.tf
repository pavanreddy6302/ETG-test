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


  
  tags = {
    cost-center-id = "CC010"
  }

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

  tags = {
  cost-center-id = "CC010"
  }
  depends_on = [
    #aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    # aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    # aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
  ]
}

# ------------------------------------------------------------
# Launch Template for EKS nodes — ensures tags on instances, volumes, and ENIs
# ------------------------------------------------------------
resource "aws_launch_template" "eks_node_lt" {
  name_prefix = "${var.cluster_name}-node-lt-"

  # (Optional) Give instances a friendly Name tag in EC2 console
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name            = "${var.cluster_name}-node"
      cost-center-id  = "CC010"    # ✅ instance tag
    }
  }

  # Tag all EBS volumes created for the nodes
  tag_specifications {
    resource_type = "volume"
    tags = {
      cost-center-id  = "CC010"    # ✅ volume tag
    }
  }

  # Tag all ENIs attached to the nodes
  tag_specifications {
    resource_type = "network-interface"
    tags = {
      cost-center-id  = "CC010"    # ✅ ENI tag
    }
  }
}