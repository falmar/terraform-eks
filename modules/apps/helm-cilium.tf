resource "helm_release" "cilium" {
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  name       = "cilium"
  version    = "1.15.1"
  namespace  = "kube-system"

  values = [
    templatefile("./modules/apps/values/cilium.yaml", {
      KUBERNETES_SERVICE_HOST = replace(var.k8s_service_endpoint, "https://", "")
      KUBERNETES_SERVICE_PORT = 443
    })
  ]

  depends_on = [
    helm_release.cilium
  ]
}
