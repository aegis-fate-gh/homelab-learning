locals {
  kubeconfig = yamldecode(data.infisical_secrets.talos_kubeconfig.secrets["KUBECONFIG"].value)

  cluster = local.kubeconfig.clusters[0].cluster
  user    = local.kubeconfig.users[0].user
}