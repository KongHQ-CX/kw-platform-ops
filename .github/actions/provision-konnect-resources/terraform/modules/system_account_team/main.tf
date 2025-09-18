terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
  }
}

resource "konnect_system_account_team" "this" {
  team_id    = var.team_id
  account_id = var.account_id
}
