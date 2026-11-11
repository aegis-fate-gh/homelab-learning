provider "proxmox" {
  endpoint  = "https://192.168.6.34:8006/"
  api_token = data.infisical_secrets.proxmox_secrets.secrets["combined_key"].value
  insecure = true
}