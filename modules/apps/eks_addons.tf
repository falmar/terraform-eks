resource "time_sleep" "wait_cilium" {
  count = var.critical_apps ? 0 : 1

  depends_on = [helm_release.cilium]

  create_duration = "90s"
}

resource "aws_eks_addon" "main_coredns" {
  count = var.critical_apps ? 0 : 1

  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.6"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = 1
    tolerations  = [
      {
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      },
      {
        effect = "NoSchedule"
        key    = "node-role.kubernetes.io/control-plane"
      },
      {
        key      = "node.cilium.io/agent-not-ready"
        operator = "Equal"
        value    = "true"
      },
      {
        key      = "node.k8s.lavieri.dev/group"
        operator = "Equal"
        value    = "controllers"
      }
    ]
    affinity = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [
                {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values   = ["linux"]
                },
                {
                  key      = "kubernetes.io/arch"
                  operator = "In"
                  values   = ["amd64", "arm64"]
                },
                {
                  key      = "node.k8s.lavieri.dev/group"
                  operator = "In"
                  values   = ["controllers"]
                }
              ]
            }
          ]
        }
      }
      podAntiAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [
          {
            podAffinityTerm = {
              labelSelector = {
                matchExpressions = [
                  {
                    key      = "k8s-app"
                    operator = "In"
                    values   = ["kube-dns"]
                  }
                ]
              }
              topologyKey = "kubernetes.io/hostname"
            }
            weight = 100
          }
        ]
      }
    }
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

  depends_on = [
    time_sleep.wait_cilium
  ]
}
