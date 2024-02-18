resource "helm_release" "ingress_nginx" {
  count = var.critical_apps > 1 ? 0 : 1

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  name             = "default"
  version          = "4.9.1"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    templatefile("./modules/apps/values/nginx.yaml", {
      PUBLIC_NLB_SG = var.public_nlb_security_group
    }),
  ]

  depends_on = [
    helm_release.cilium,
    kubectl_manifest.eks_elb_controller,
    helm_release.cert_manager,
    aws_eks_addon.main_coredns,
  ]
}
