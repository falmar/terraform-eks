resource "aws_eks_node_group" "storage" {
  count = (var.bootstrap || var.critical_apps) ? 0 : 1

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "storage"
  node_role_arn   = aws_iam_role.eks_main_worker_node.arn
  subnet_ids      = aws_subnet.backend[*].id

  ami_type      = "AL2_ARM_64"
  capacity_type = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 2
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
    value  = "storage"
    effect = "NO_EXECUTE"
  }
  labels = {
    "node.k8s.lavieri.dev/group" = "storage"
  }

  launch_template {
    version = aws_launch_template.eks_storage.latest_version
    id      = aws_launch_template.eks_storage.id
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

resource "aws_launch_template" "eks_storage" {
  name_prefix            = "${local.project_name}-storage"
  key_name               = aws_key_pair.debug.key_name
  vpc_security_group_ids = [
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id,
    aws_security_group.internet.id,
    aws_security_group.public_nlb_target.id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
  # extra 50gb gp3 volume
  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }

  user_data = base64encode(<<-UDEOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Format the disk | TODO: ask about block size
sudo mkfs -t xfs /dev/nvme1n1

# Capture the UUID
export uuid=$(sudo blkid -s UUID -o value /dev/nvme1n1)

# Create a mount point
sudo mkdir -p /mnt/ssds/$uuid

# Mount the disk
sudo mount /dev/nvme1n1 /mnt/ssds/$uuid

# Add entry to /etc/fstab
sudo tee -a /etc/fstab << EOF
UUID=$uuid /mnt/ssds/$uuid xfs defaults,nofail 0 2
EOF

--==MYBOUNDARY==--
UDEOF
)
}
