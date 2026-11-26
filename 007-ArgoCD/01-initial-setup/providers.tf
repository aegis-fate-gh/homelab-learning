terraform {
  required_providers {
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.20"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"
    key    = "homelab/argocd/terraform.tfstate"
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

provider "helm" {
  kubernetes = {
    host                   = local.cluster.server
    cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.user["client-certificate-data"])
    client_key             = base64decode(local.user["client-key-data"])
  }
}

provider "kubectl" {
  host                   = local.cluster.server
  cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.user["client-certificate-data"])
  client_key             = base64decode(local.user["client-key-data"])
  load_config_file         = false
}

provider "kubernetes" {
  host                   = local.cluster.server
  cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.user["client-certificate-data"])
  client_key             = base64decode(local.user["client-key-data"])
}
