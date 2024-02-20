resource "kubectl_manifest" "eks_elb_sa" {
  override_namespace = "kube-system"
  yaml_body          = templatefile("./modules/apps/assets/aws-lb-sa.yaml", {
    ACCOUNT_ID = var.account_id,
    ROLE_NAME  = aws_iam_role.eks_elb.name
  })
  depends_on = [aws_iam_role.eks_elb]
}

resource "aws_iam_role" "eks_elb" {
  name               = "${var.project_name}-AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.elb_assume_role.json
}
resource "aws_iam_role_policy" "AWSLoadBalancerControllerIAMPolicy" {
  role   = aws_iam_role.eks_elb.name
  policy = file("./modules/apps/assets/aws-lb-policy.json")
}
data "aws_iam_policy_document" "elb_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [
        var.oidc_provider_arn
      ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "kubectl_file_documents" "eks_elb_controller" {
  count   = var.critical_apps > 1 ? 0 : 1
  content = templatefile("./modules/apps/assets/aws-lb-v2_7_1_full.yaml", {
    CLUSTER_NAME = var.cluster_name
  })
}
resource "kubectl_manifest" "eks_elb_controller" {
  override_namespace = "kube-system"
  count              = var.critical_apps > 1 ? 0 : length(data.kubectl_file_documents.eks_elb_controller[0].documents)
  yaml_body          = element(data.kubectl_file_documents.eks_elb_controller[0].documents, count.index)

  force_conflicts = true

  depends_on = [
    aws_iam_role.eks_elb,
    aws_iam_role_policy.AWSLoadBalancerControllerIAMPolicy,
    helm_release.cert_manager,
  ]
}
