resource "aws_iam_role" "eks_ebs_csi" {
  name               = "${var.project_name}-AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}
resource "aws_iam_role_policy" "eks_AmazonEBSCSIDriverPolicy" {
  role   = aws_iam_role.eks_ebs_csi.name
  policy = file("./modules/apps/assets/aws-ebs-csi-policy.json")
}
data "aws_iam_policy_document" "ebs_csi_assume_role" {
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
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "helm_release" "ebs_csi_controller" {
  count = var.critical_apps > 1 ? 0 : 1

  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  name             = "aws-ebs-csi-driver"
  version          = "2.28.0"
  namespace        = "kube-system"
  create_namespace = true

  values = [
    templatefile("./modules/apps/values/ebs-csi.yaml", {
      ACCOUNT_ID = var.account_id,
      ROLE_NAME  = aws_iam_role.eks_ebs_csi.name
    }),
  ]

  depends_on = [
    helm_release.cilium,
    helm_release.cert_manager,
    aws_iam_role.eks_ebs_csi,
  ]
}
