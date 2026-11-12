locals {
  infisical_workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  infisical_env_slug     = "prod"
  infisical_folder_path  = "/talos"

  install_patch = <<-EOT
    apiVersion: v1alpha1
    kind: UnattendedInstallConfig
    installer:
      image: ${data.talos_image_factory_urls.this.urls.installer}
    provisioning:
      diskSelector:
        match: disk.dev_path == "/dev/vda"
      wipe: true
  EOT
}