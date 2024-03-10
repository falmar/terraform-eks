data "kustomization_build" "deployment" {
  path = "./modules/apps/deployment"
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "deployment" {
  for_each = var.critical_apps > 0 ? [] : data.kustomization_build.deployment.ids_prio[0]

  manifest = (
  contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
  ? sensitive(data.kustomization_build.deployment.manifests[each.value])
  : data.kustomization_build.deployment.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
resource "kustomization_resource" "deployment_p1" {
  for_each = var.critical_apps > 0 ? [] : data.kustomization_build.deployment.ids_prio[1]

  manifest = (
  contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
  ? sensitive(data.kustomization_build.deployment.manifests[each.value])
  : data.kustomization_build.deployment.manifests[each.value]
  )

  depends_on = [kustomization_resource.deployment]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "deployment_p2" {
  for_each = var.critical_apps > 0 ? [] : data.kustomization_build.deployment.ids_prio[2]

  manifest = (
  contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
  ? sensitive(data.kustomization_build.deployment.manifests[each.value])
  : data.kustomization_build.deployment.manifests[each.value]
  )

  depends_on = [kustomization_resource.deployment_p1]
}
