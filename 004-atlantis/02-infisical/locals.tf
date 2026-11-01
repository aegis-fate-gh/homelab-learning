locals {
    zone_id    = data.infisical_secrets.common_secrets.secrets["zone_id"].value
    account_id = data.infisical_secrets.common_secrets.secrets["account_id"].value
    domain     = data.infisical_secrets.common_secrets.secrets["domain_name"].value
    ip_address = data.infisical_secrets.common_secrets.secrets["ip_address"].value
}