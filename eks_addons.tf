resource "aws_eks_addon" "main_kube_proxy" {
  count        = var.bootstrap ? 1 : 0
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Avoid deploying kube-proxy at all costs

  depends_on = [
    aws_eks_cluster.main,
  ]
}
resource "aws_eks_addon" "main_vpc_cni" {
  count        = var.bootstrap ? 1 : 0
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Avoid deploying vpc-cni at all costs

  depends_on = [
    aws_eks_cluster.main,
  ]
}
