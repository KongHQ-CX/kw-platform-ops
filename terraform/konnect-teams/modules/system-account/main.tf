terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  days_to_hours   = 365 * 24 // 1 year
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

### Foreach team, create system accounts
resource "konnect_system_account" "this" {

  name        = "sa-${var.team_name}"
  description = "System account for creating control planes for the ${var.team_name} team"

  konnect_managed = false
}

# Assign the system accounts to the teams
resource "konnect_system_account_team" "this" {
  team_id = var.team_id

  account_id = konnect_system_account.this.id
}

### Add the control plane creator role if team has the entitlement
resource "konnect_system_account_role" "cp_creators" {
  count            = contains(var.team_entitlements, "konnect.control_plane") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "Control Planes"
  role_name        = "Creator"
  account_id       = konnect_system_account.this.id
}

### Add the control plane viewer role if team has the entitlement
resource "konnect_system_account_role" "cp_viewers" {
  count            = contains(var.team_entitlements, "konnect.control_plane") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  account_id       = konnect_system_account.this.id
}

### Add the control plane Admin if the team has the entitlement
resource "konnect_system_account_role" "cp_admins" {
  count            = contains(var.team_entitlements, "konnect.control_plane.admin") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  account_id       = konnect_system_account.this.id
}

### Add the api product creator role if team has the entitlement
resource "konnect_system_account_role" "ap_creators" {
  count            = contains(var.team_entitlements, "konnect.api_product") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "API Products"
  role_name        = "Creator"
  account_id       = konnect_system_account.this.id
}

### Add the api product viewer role to every team system account
resource "konnect_system_account_role" "ap_viewers" {
  count            = contains(var.team_entitlements, "konnect.api_product") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "API Products"
  role_name        = "Viewer"
  account_id       = konnect_system_account.this.id
}

### Add the api creator role if team has the entitlement
resource "konnect_system_account_role" "api_creators" {
  count            = contains(var.team_entitlements, "konnect.api") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "APIs"
  role_name        = "Creator"
  account_id       = konnect_system_account.this.id
}

### Add the api viewer role if team has the entitlement
resource "konnect_system_account_role" "api_viewers" {
  count            = contains(var.team_entitlements, "konnect.api") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "APIs"
  role_name        = "Viewer"
  account_id       = konnect_system_account.this.id
}

### Add the api publisher role if team has the entitlement
resource "konnect_system_account_role" "api_publishers" {
  count            = contains(var.team_entitlements, "konnect.api") ? 1 : 0

  entity_id        = "*"
  entity_region    = "eu" # Hardcoded for now
  entity_type_name = "APIs"
  role_name        = "Publisher"
  account_id       = konnect_system_account.this.id
}

# Create an access token for every system account
resource "konnect_system_account_access_token" "this" {
  name       = "${konnect_system_account.this.name}-token"
  expires_at = local.expiration_date
  account_id = konnect_system_account.this.id

}

output "system_account_token" {
  value = konnect_system_account_access_token.this.token

  sensitive = true
}
