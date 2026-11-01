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

# Create the tunnel itself
resource "cloudflare_zero_trust_tunnel_cloudflared" "staging_tunnel" {
	account_id    = var.account_id
	name          = "terraform_test"
	config_src    = "cloudflare"
}

# Obtains the Tunnel ID
data "cloudflare_zero_trust_tunnel_cloudflared_token" "staging_tunnel_token" {
	account_id 	= var.account_id
	tunnel_id 	= cloudflare_zero_trust_tunnel_cloudflared.staging_tunnel.id
}

# Create the DNS record
resource "cloudflare_dns_record" "staging_dns_record" {
  name    = "staging"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  comment = "Managed with Terraform"
  content   = "${cloudflare_zero_trust_tunnel_cloudflared.staging_tunnel.id}.cfargotunnel.com"
  zone_id = var.zone_id
}

# Create the Route
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "staging_tunnel_route" {
  account_id = var.account_id
  network = "172.16.0.0/16"
  tunnel_id = "${cloudflare_zero_trust_tunnel_cloudflared.staging_tunnel.id}"
  comment = "Managed with Terraform"
}

# Create the published application
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "staging_tunnel_cloudflared_config" {
  account_id = var.account_id
  tunnel_id = "${cloudflare_zero_trust_tunnel_cloudflared.staging_tunnel.id}"
  config = {
    ingress = [
        {
            hostname = "staging.${var.domain_name}"
            service = "https://localhost:8001"
        },
        {
            service = "http_status:404"
    }]
  }
}