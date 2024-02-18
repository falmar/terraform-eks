resource "aws_key_pair" "debug" {
  public_key = file("./secrets/ssh/debug.pub")
  key_name = "${local.project_name}-debug"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_main_worker_node" {
  name               = "${local.project_name}-main-worker-node"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
resource "aws_iam_role_policy_attachment" "eks_main_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_main_worker_node.name
}
resource "aws_iam_role_policy_attachment" "eks_main_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_main_worker_node.name
}
resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_main_worker_node.name
}

#resource "aws_iam_role" "eks_main_cni" {
#  name               = "${local.project_name}-main-cni"
#  assume_role_policy = data.aws_iam_policy_document.cni_assume_role.json
#}
#resource "aws_iam_role_policy_attachment" "main_cni_AmazonEKSCNIPolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#  role       = "${aws_iam_role.eks_main_cni.name}"
#}
#data "aws_iam_policy_document" "cni_assume_role" {
#  statement {
#    effect = "Allow"
#
#    principals {
#      type        = "Federated"
#      identifiers = [
#        aws_iam_openid_connect_provider.main.arn
#      ]
#    }
#
#    actions = ["sts:AssumeRoleWithWebIdentity"]
#
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub"
#      values   = ["system:serviceaccount:kube-system:aws-node"]
#    }
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:aud"
#      values   = ["sts.amazonaws.com"]
#    }
#  }
#}
