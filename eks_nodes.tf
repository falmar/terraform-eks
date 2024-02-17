resource "aws_key_pair" "debug" {
  public_key = file("~/.ssh/id_rsa.pub")
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
resource "aws_iam_role_policy_attachment" "eks_main_AmazonEKSCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_main_worker_node.name
}

#resource "aws_iam_role" "eks_main_cni" {
#  name               = "${local.project_name}-main-cni"
#  assume_role_policy = data.aws_iam_policy_document.cni_assume_role.json
#}
#resource "aws_iam_role_policy_attachment" "main_AmazonEKSCNIPolicy" {
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
#        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${aws_eks_cluster.main.identity[0].oidc[0].issuer}"
#      ]
#    }
#
#    actions = ["sts:AssumeRoleWithWebIdentity"]
#
#    condition {
#      test     = "StringEquals"
#      variable = "${aws_eks_cluster.main.identity[0].oidc[0].issuer}:sub"
#      values   = ["system:serviceaccount:kube-system:aws-node"]
#    }
#    condition {
#      test     = "StringEquals"
#      variable = "${aws_eks_cluster.main.identity[0].oidc[0].issuer}:aud"
#      values   = ["sts.amazonaws.com"]
#    }
#  }
#}
