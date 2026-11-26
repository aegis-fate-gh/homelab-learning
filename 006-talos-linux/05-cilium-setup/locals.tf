locals {
  gw_base = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/${var.gateway_api_version}/config/crd/standard"

  gateway_api_crds = toset([
    "gateway.networking.k8s.io_gatewayclasses.yaml",
    "gateway.networking.k8s.io_gateways.yaml",
    "gateway.networking.k8s.io_httproutes.yaml",
    "gateway.networking.k8s.io_referencegrants.yaml",
    "gateway.networking.k8s.io_grpcroutes.yaml",
    "gateway.networking.k8s.io_tlsroutes.yaml",
    "gateway.networking.k8s.io_backendtlspolicies.yaml",
    # Optional, new in Cilium 1.20 (uncomment if you want them):
    # "gateway.networking.k8s.io_listenersets.yaml",
    # "gateway.networking.k8s.io_udproutes.yaml",
  ])

  kubeconfig = yamldecode(data.infisical_secrets.talos_kubeconfig.secrets["KUBECONFIG"].value)

  cluster = local.kubeconfig.clusters[0].cluster
  user    = local.kubeconfig.users[0].user
}