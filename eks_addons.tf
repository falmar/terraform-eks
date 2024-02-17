resource "aws_eks_addon" "main_coredns" {
  count = 0
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  addon_version = "v1.11.1-eksbuild.6"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = 3
    resources = {
      limits = {
        cpu    = "100m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  })
}
