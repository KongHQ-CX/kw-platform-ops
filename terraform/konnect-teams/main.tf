terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  config               = yamldecode(file(var.config_file))
  metadata             = lookup(local.config, "metadata", {})
  teams                = [for team in lookup(local.config, "resources", []) : team if lookup(team, "offboarded", false) != true]
  sanitized_team_names = { for team in local.teams : team.name => replace(lower(team.name), " ", "-") }
}


################################################################################
# STEP 1: CREATE THE KONNECT TEAMS
################################################################################

resource "konnect_team" "this" {
  for_each = { for team in local.teams : team.name => team }

  description = lookup(each.value, "description", null)
  labels = merge(lookup(each.value, "labels", {
    "generated_by" = "terraform"
  }))
  name = each.value.name
}


################################################################################
# STEP 2: CREATE THE KONNECT SYSTEM ACCOUNTS FOR EACH TEAM
################################################################################
module "system-account" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/system-account"

  team_name         = local.sanitized_team_names[each.value.name]
  team_entitlements = try([for t in local.teams : t.entitlements if t.name == each.value.name][0], [])
  team_id           = each.value.id
}


################################################################################
# STEP 3: CREATE THE TEAMS GITHUB REPOSITORIES
# (Not in Scope for the Demo)
################################################################################


#########################################################################################
# STEP 4: CREATE THE VAULT INTEGRATIONS FOR EACH TEAM AND STORE THE SYSTEM ACCOUNT TOKENS
#########################################################################################
module "vault" {
  for_each = { for team in konnect_team.this : team.name => team }

  source = "./modules/vault"

  team_name                  = local.sanitized_team_names[each.value.name]
  system_account_secret_path = "system-accounts/sa-${local.sanitized_team_names[each.value.name]}"
  system_account_token       = module.system-account[each.value.name].system_account_token
}
