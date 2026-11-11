terraform {
  required_providers {
    unifi = {
      source = "ubiquiti-community/unifi"
      version = "0.65.0"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.20" # Use the latest available version
    }
  }
}

data "infisical_secrets" "unifi_secrets" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/unifi"
}

data "unifi_network" "staging_network" {
  name = "Staging"
}

data "unifi_network" "staging_vlan" {
  id = data.unifi_network.staging_network.id
}

resource "unifi_client" "test" {
  for_each = { for idx, client in var.clients : idx => client }
  mac  = each.value.mac
  name = each.value.name
  note = "Created by OpenTofu"

  fixed_ip   = each.value.ip
  network_id = data.unifi_network.staging_vlan.id
}