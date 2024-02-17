#resource "aws_iam_role" "eks_main_lb" {
#  name               = "${local.project_name}-main-lb"
#  assume_role_policy = data.aws_iam_policy_document.lb_assume_role.json
#}
#resource "aws_iam_role_policy" "main_lb_AWSLoadBalancerControllerIAMPolicy" {
#  role   = aws_iam_role.eks_main_lb.name
#  policy = file("./assets/aws-lb-policy.json")
#}
#
#data "aws_iam_policy_document" "lb_assume_role" {
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
#      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#    }
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:aud"
#      values   = ["sts.amazonaws.com"]
#    }
#  }
#}
#
#data "kubectl_file_documents" "eks_main_lb_controller" {
#  content = templatefile("./assets/aws-lb-v2_7_1_full.yaml", {
#    CLUSTER_NAME = aws_eks_cluster.main.name
#  })
#}
#resource "kubectl_manifest" "eks_main_lb_controller" {
#  for_each  = data.kubectl_file_documents.eks_main_lb_controller.manifests
#  yaml_body = each.value
#
#  depends_on = [
#    aws_iam_role.eks_main_lb,
#    aws_iam_role_policy.main_lb_AWSLoadBalancerControllerIAMPolicy
#  ]
#}
#
#resource "kubectl_manifest" "eks_main_lb_sa" {
#  yaml_body = templatefile("./assets/aws-lb-sa.yaml", {
#    ACCOUNT_ID = data.aws_caller_identity.current.account_id
#    ROLE_NAME  = aws_iam_role.eks_main_lb.name
#  })
#  depends_on = [aws_iam_role.eks_main_lb]
#}
