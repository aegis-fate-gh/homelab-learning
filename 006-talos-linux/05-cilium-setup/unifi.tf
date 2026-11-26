data "infisical_secrets" "unifi_secrets" {
  env_slug     = "prod"
  workspace_id = "e51c67f1-70bc-4471-b231-ec4ea32ad854"
  folder_path  = "/unifi"
}

resource "unifi_dns_record" "host_a" {
  name        = "*.talos-test.local.sch-apps.com"
  record_type = "A"
  value       = var.cilium_ingress_ip
  ttl         = "5m"
}