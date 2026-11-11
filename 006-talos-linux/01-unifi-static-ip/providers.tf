# https://search.opentofu.org/provider/ubiquiti-community/unifi/latest
provider "unifi" {
  username = data.infisical_secrets.unifi_secrets.secrets["username"].value
  password = data.infisical_secrets.unifi_secrets.secrets["password"].value
  api_url = "https://192.168.100.1"
  allow_insecure = true
}