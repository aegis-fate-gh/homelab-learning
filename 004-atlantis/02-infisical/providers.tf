provider "infisical" {}

provider "cloudflare" {
  api_token = data.infisical_secrets.common_secrets.secrets["api_token"].value
}