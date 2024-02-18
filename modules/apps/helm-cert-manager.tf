data "kubectl_file_documents" "cert_manager" {
  content = file("./modules/apps/crds/cert-manager.yaml")
}
resource "kubectl_manifest" "cert_manager" {
  for_each  = data.kubectl_file_documents.cert_manager.manifests
  yaml_body = each.value

  depends_on = [
    helm_release.cilium
  ]
}

resource "helm_release" "cert_manager" {
  count = var.critical_apps ? 0 : 1

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  name             = "cert-manager"
  version          = "1.14.2"
  namespace        = "cert-manager"
  create_namespace = true

  values = [file("./modules/apps/values/cert-manager.yaml")]

  depends_on = [
    kubectl_manifest.cert_manager,
    aws_eks_addon.main_coredns
  ]
}
