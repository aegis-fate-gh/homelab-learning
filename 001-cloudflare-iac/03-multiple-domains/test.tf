terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

variable "applications" {
  type = list(object({
    name = string
    service = string
  }))
  default = [
    { name = "app1", service = "https://localhost:8001" },
    { name = "app2", service = "https://localhost:8002" },
    { name = "app3", service = "https://localhost:8003" },
    { name = "app4", service = "https://localhost:8004" },
    { name = "app5", service = "https://localhost:8005" }
  ]
  description = "List of domains to create"
}

locals {
  ingress_rules = [
    for app in var.applications : {
      hostname = app.name
      service = app.service
    }
  ]
}

provider "cloudflare" {
  api_token = var.api_token
}

# Create the tunnel itself. They are not deleted when destroyed by Terraform
resource "cloudflare_zero_trust_tunnel_cloudflared" "testing_tunnel" {
	account_id    = var.account_id
	name          = "terraform_test_multiple"
	config_src    = "cloudflare"
}

# Obtains the Tunnel ID
data "cloudflare_zero_trust_tunnel_cloudflared_token" "testing_tunnel_token" {
	account_id 	= var.account_id
	tunnel_id 	= cloudflare_zero_trust_tunnel_cloudflared.testing_tunnel.id
}

# Create the DNS record
resource "cloudflare_dns_record" "testing_dns_record" {
  for_each = { for app in var.applications : app.name => app }
    name    = "${each.value.name}"
    proxied = true
    ttl     = 1
    type    = "CNAME"
    comment = "Managed with Terraform"
    content   = "${cloudflare_zero_trust_tunnel_cloudflared.testing_tunnel.id}.cfargotunnel.com"
    zone_id = var.zone_id
}

# Create the Route
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "testing_tunnel_route" {
  account_id = var.account_id
  network = "175.16.0.0/16"
  tunnel_id = "${cloudflare_zero_trust_tunnel_cloudflared.testing_tunnel.id}"
  comment = "Managed with Terraform"
}

# Create the published application. They are not deleted when destroyed by Terraform
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "testing_tunnel_cloudflared_config" {
  account_id = var.account_id
  tunnel_id = "${cloudflare_zero_trust_tunnel_cloudflared.testing_tunnel.id}"
  config = {
    ingress = concat(local.ingress_rules, [
        {
            service = "http_status:404"
    }])
  }
}