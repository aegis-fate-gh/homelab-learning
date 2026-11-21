terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.20"
    }
  }
  backend "s3" {
    bucket = "tfstate"
    key    = "homelab/talos_3/terraform.tfstate"
    region = "us-east-1"   # required by Terraform, not meaningful to RustFS

    endpoints      = { s3 = "http://rustfs:9000" }
    use_path_style = true

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true

    use_lockfile = true
  }
}
