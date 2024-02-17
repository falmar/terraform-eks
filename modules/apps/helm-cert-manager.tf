resource "helm_release" "cert_manager" {
  count = var.bootstrap ? 0 : 1

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  name             = "cert-manager"
  version          = "1.14.2"
  namespace        = "cert-manager"
  create_namespace = true

  values = [file("./modules/apps/values/cert-manager.yaml")]

  depends_on = [
    helm_release.cilium
  ]
}
