// https://kubernetes-sigs.github.io/external-dns/
resource "helm_release" "external_dns" {
  count = var.critical_apps > 0 ? 0 : 1

  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  name       = "external-dns"
  version    = "1.14.3"
  namespace  = "external-dns"
  create_namespace = true

  values = [file("./modules/apps/values/external-dns.yaml")]

  depends_on = [
    helm_release.cilium,
    aws_eks_addon.main_coredns,
    helm_release.ingress_nginx,
  ]
}
