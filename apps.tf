module "apps" {
  source = "./modules/apps"

  bootstrap                 = var.bootstrap
  k8s_service_endpoint      = aws_eks_cluster.main.endpoint
  public_nlb_security_group = aws_security_group.public_nlb.id

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.controllers
  ]
}
