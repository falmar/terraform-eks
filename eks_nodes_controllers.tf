resource "aws_eks_node_group" "controllers" {
  count = (var.bootstrap) ? 0 : 1

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "controllers"
  node_role_arn   = aws_iam_role.eks_main_worker_node.arn
  subnet_ids      = aws_subnet.backend[*].id

  ami_type      = "AL2_ARM_64"
  capacity_type = "SPOT"

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 0
  }

  instance_types = [
    "t4g.small"
  ]

  taint {
    key    = "node.cilium.io/agent-not-ready"
    value  = "true"
    effect = "NO_EXECUTE"
  }
  taint {
    key    = "node.k8s.lavieri.dev/group"
    value  = "controllers"
    effect = "NO_SCHEDULE"
  }
  labels = {
    "node.k8s.lavieri.dev/group" = "controllers"
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    version = aws_launch_template.eks_controllers.latest_version
    id      = aws_launch_template.eks_controllers.id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_main_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_main_AmazonEC2ContainerRegistryReadOnly,
  ]
}

#output "cni_role_name" {
#  value = aws_iam_role.eks_main_cni.name
#}

resource "aws_launch_template" "eks_controllers" {
  name_prefix            = "${local.project_name}-controllers"
  key_name               = aws_key_pair.debug.key_name
  vpc_security_group_ids = [
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id,
    aws_security_group.internet.id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
}
