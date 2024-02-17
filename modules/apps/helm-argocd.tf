resource "helm_release" "argocd" {
  count = var.bootstrap ? 0 : 1

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  name       = "argocd"
  version    = "6.1.0"
  namespace  = "argocd"
  create_namespace = true

  values = [file("./modules/apps/values/argocd.yaml")]

  depends_on = [helm_release.cilium]
}
