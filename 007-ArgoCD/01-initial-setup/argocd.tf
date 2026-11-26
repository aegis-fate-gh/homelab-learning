data "infisical_secrets" "talos_kubeconfig" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/talos"
}

resource "helm_release" "argocd" {
    name       = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-cd"
    version    = var.argocd_version
    namespace        = "argocd"
    create_namespace = true
    wait             = true

    values = [yamlencode({
      createClusterRoles = true
      global = {
        clusterAdminAccess = {
          enabled = true
        }
        domain = "argocd.talos-test.local.sch-apps.com"
      }

      configs = {
        params = {
          "server.insecure"        = true
          "application.namespaces" = "*"
        }
      }

      server = {
        replicas = 2
        ingress = {
          enabled = true
          ingressClassName = "cilium"
          tls = true
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-cloudflare"
          }
        }
      }

      "redis-ha" = {
        enabled = true
      }

      controller = {
        replicas = 1
      }

      repoServer = {
        replicas = 2
      }

      applicationSet = {
        replicas          = 2
        allowAnyNamespace = true
      }
    })
  ]
}

