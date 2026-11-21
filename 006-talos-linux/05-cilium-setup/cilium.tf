data "http" "gateway_api_crd" {
  for_each = local.gateway_api_crds
  url      = "${local.gw_base}/${each.value}"
}

data "infisical_secrets" "talos_kubeconfig" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/talos"
}

data "infisical_secrets" "cilium_secrets" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/cilium"
}

resource "kubectl_manifest" "gateway_api_crd" {
  for_each          = { for name, d in data.http.gateway_api_crd : name => d.response_body }
  yaml_body         = each.value
  server_side_apply = true
  force_conflicts   = true
  wait              = true
}

resource "helm_release" "cilium" {
    depends_on = [kubectl_manifest.gateway_api_crd]
    name       = "cilium"
    namespace  = "kube-system"
    repository = "https://helm.cilium.io"
    chart      = "cilium"
    version    = var.cilium_version

    values = [yamlencode({
      ipam = { mode = "kubernetes" }
      kubeProxyReplacement = true
      gatewayAPI = { enabled = true }
      k8sServiceHost = "localhost"   # KubePrism
      k8sServicePort = 7445
      cgroup = {
      autoMount = { enabled = false }
      hostRoot  = "/sys/fs/cgroup"
      }
      securityContext = {
      capabilities = {
          ciliumAgent      = ["CHOWN","KILL","NET_ADMIN","NET_RAW","IPC_LOCK","SYS_ADMIN","SYS_RESOURCE","DAC_OVERRIDE","FOWNER","SETGID","SETUID"]
          cleanCiliumState = ["NET_ADMIN","SYS_ADMIN","SYS_RESOURCE"]
      }
      }
      l2announcements = { enabled = true }
      k8sClientRateLimit = { qps = 20, burst = 40 }  # recommended with L2 announcements
      hubble = { relay = { enabled = true }, ui = { enabled = true } }
    })]
}

resource "kubectl_manifest" "lb_pool" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata   = { name = "homelab" }
    spec = { blocks = [{ start = "192.168.7.2", stop = "192.168.7.9" }] }
  })
  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "l2_policy" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata   = { name = "default" }
    spec = { loadBalancerIPs = true, interfaces = ["eth0"] }  # match your NIC names
  })
  depends_on = [helm_release.cilium]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version

  values = [yamlencode({
    crds   = { enabled = true }        # older chart versions use installCRDs = true
    config = {
      apiVersion = "controller.config.cert-manager.io/v1alpha1"
      kind       = "ControllerConfiguration"
      enableGatewayAPI = true
    }
  })]
  depends_on = [helm_release.cilium]
}

resource "kubernetes_secret_v1" "cloudflare_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }
  type = "Opaque"

  data       = { api-token = data.infisical_secrets.cilium_secrets.secrets["CF_Token"].value }
  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "letsencrypt-cloudflare" }
    spec = {
      acme = {
        server              = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email               = data.infisical_secrets.cilium_secrets.secrets["EMAIL"].value
        privateKeySecretRef = { name = "letsencrypt-account-key" }
        solvers = [{
          dns01 = { cloudflare = { apiTokenSecretRef = { name = "cloudflare-api-token", key = "api-token" } } }
        }]
      }
    }
  })
  depends_on = [kubernetes_secret_v1.cloudflare_token]
}