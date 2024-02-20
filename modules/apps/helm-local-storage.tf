data "kubectl_file_documents" "local_storage" {
  count   = var.critical_apps > 0 ? 0 : 1
  content = file("./modules/apps/assets/local-storage.yaml")
}
resource "kubectl_manifest" "local_storage" {
  count     = var.critical_apps > 0 ? 0 : length(data.kubectl_file_documents.local_storage[0].documents)
  yaml_body = element(data.kubectl_file_documents.local_storage[0].documents, count.index)

  depends_on = [
    helm_release.cilium
  ]
}


resource "helm_release" "local_storage" {
  count = var.critical_apps > 1 ? 0 : 1

  repository       = "https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner"
  chart            = "local-static-provisioner"
  name             = "local-static-provisioner"
  version          = "2.0.0"
  namespace        = "kube-system"
  create_namespace = true

  values = [
    file("./modules/apps/values/local-storage.yaml"),
  ]

  depends_on = [
    helm_release.cilium,
    helm_release.cert_manager,
    kubectl_manifest.local_storage
  ]
}
