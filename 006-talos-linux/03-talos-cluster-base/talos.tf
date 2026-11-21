resource "talos_machine_secrets" "this" {}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = ["siderolabs/qemu-guest-agent"]
      }
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version = "v1.14.5"
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [local.install_patch]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [local.install_patch]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.node_data.controlplanes : k]
  nodes                = [for k, v in var.node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.node_data.controlplanes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key
  config_patches = [<<-EOT
    apiVersion: v1alpha1
    kind: HostnameConfig
    hostname: ${each.value.hostname}
    auto: off
  EOT
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.node_data.workers
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
  config_patches = [<<-EOT
    apiVersion: v1alpha1
    kind: HostnameConfig
    hostname: ${each.value.hostname}
    auto: off
  EOT
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]
  node                 = keys(var.node_data.controlplanes)[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "time_sleep" "after_bootstrap" {
  depends_on      = [talos_machine_bootstrap.this]
  create_duration = "90s"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [time_sleep.after_bootstrap]
  node                 = keys(var.node_data.controlplanes)[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "infisical_secret" "kubeconfig" {
  name         = "KUBECONFIG"
  value        = talos_cluster_kubeconfig.this.kubeconfig_raw
  env_slug     = local.infisical_env_slug
  workspace_id = local.infisical_workspace_id
  folder_path  = local.infisical_folder_path
}

resource "infisical_secret" "talosconfig" {
  name         = "TALOSCONFIG"
  value        = data.talos_client_configuration.this.talos_config
  env_slug     = local.infisical_env_slug
  workspace_id = local.infisical_workspace_id
  folder_path  = local.infisical_folder_path
}