terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.20" # Use the latest available version
    }
  }
}

data "infisical_secrets" "common_secrets" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/cloudflare/stephen-hudgins"
}

# Create the DNS record
resource "cloudflare_dns_record" "staging_test" {
  name    = "staging"
  proxied = true
  ttl     = 1
  type    = "A"
  comment = "Managed with Terraform"
  content = local.ip_address
  zone_id = local.zone_id
}