terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.api_token
}

# Create the DNS record
resource "cloudflare_dns_record" "staging_test" {
  name    = "staging"
  proxied = true
  ttl     = 1
  type    = "A"
  comment = "Managed with Terraform"
  content   = var.ip_address
  zone_id = var.zone_id
}