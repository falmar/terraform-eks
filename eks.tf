resource "aws_eks_cluster" "main" {
  name     = "${local.project_name}-main"
  role_arn = aws_iam_role.eks_main_cluster.arn

  vpc_config {
    subnet_ids = concat(aws_subnet.backend.*.id, aws_subnet.frontend.*.id)

    endpoint_public_access  = true
    endpoint_private_access = true

    security_group_ids = [
        aws_security_group.internet.id,
    ]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  kubernetes_network_config {
    ip_family = "ipv4"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_main_AmazonEKSClusterPolicy
  ]
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "eks_main_cluster" {
  name               = "${local.project_name}-main-cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}
resource "aws_iam_role_policy_attachment" "eks_main_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_main_cluster.name
}

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.main.url
}
