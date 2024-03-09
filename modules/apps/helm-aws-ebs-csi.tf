resource "aws_iam_role" "aws_ebs_csi" {
  name               = "${var.project_name}-AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn,
        },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          },
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        },
      },
    ],
  })
}
resource "aws_iam_role_policy" "AmazonEBSCSIDriverPolicy" {
  role   = aws_iam_role.aws_ebs_csi.name
  policy = file("./modules/apps/assets/aws-ebs-csi-policy.json")
}

resource "helm_release" "aws_ebs_csi_controller" {
  count = var.critical_apps > 1 ? 0 : 1

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  name       = "aws-ebs-csi-driver"
  version    = "2.28.0"
  namespace  = "kube-system"

  values = [
    templatefile("./modules/apps/values/ebs-csi.yaml", {
      ACCOUNT_ID = var.account_id,
      ROLE_NAME  = aws_iam_role.aws_ebs_csi.name
    }),
  ]

  depends_on = [
    helm_release.cilium,
    helm_release.cert_manager,
    aws_iam_role.aws_ebs_csi,
  ]
}
