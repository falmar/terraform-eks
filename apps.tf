module "apps" {
  count = var.bootstrap ? 0 : 1
  source = "./modules/apps"

  critical_apps    = var.critical_apps
  project_name = local.project_name

  account_id                = data.aws_caller_identity.current.account_id
  cluster_name              = aws_eks_cluster.main.name
  k8s_service_endpoint      = aws_eks_cluster.main.endpoint
  public_nlb_security_group = aws_security_group.public_nlb.id
  oidc_provider_arn         = aws_iam_openid_connect_provider.main.arn
  oidc_provider_url         = aws_iam_openid_connect_provider.main.url

  depends_on = [
    aws_eks_cluster.main,
    null_resource.main_kubeconfig,
  ]
}
