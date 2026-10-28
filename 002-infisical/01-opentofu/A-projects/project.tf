terraform {
  required_providers {
    infisical = {
      # version = <latest version>
      source = "infisical/infisical"
    }
  }
}

provider "infisical" {
  host = var.host
  auth = {
    universal = {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }
}

resource "infisical_project" "test-project" {
  name        = "Test Project"
  slug        = "test-project"
  description = "This is a test project"
  type        = "secret-manager" # Default project type
}