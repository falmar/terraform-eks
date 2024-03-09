resource "aws_iam_role" "aws_lb_controller" {
  name               = "${var.project_name}-AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn
        },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          },
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ],
  })
}
resource "aws_iam_role_policy" "AmazonLoadBalancerControllerIAMPolicy" {
  role   = aws_iam_role.aws_lb_controller.name
  policy = file("./modules/apps/assets/aws-lb-policy.json")
}

resource "helm_release" "aws_lb_controller" {
  count = var.critical_apps > 1 ? 0 : 1

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  name       = "aws-load-balancer-controller"
  version    = "1.7.1"
  namespace  = "kube-system"

  values = [
    templatefile("./modules/apps/values/lb.yaml", {
      CLUSTER_NAME = var.cluster_name,
      ACCOUNT_ID   = var.account_id,
      ROLE_NAME    = aws_iam_role.aws_lb_controller.name
    }),
  ]

  depends_on = [
    helm_release.cilium,
    helm_release.cert_manager,
    aws_iam_role.aws_lb_controller,
  ]
}
