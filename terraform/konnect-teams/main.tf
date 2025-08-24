terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  config_files = fileset("${var.resources_path}", "*.yaml")
  teams               = [
    for file in local.config_files : 
    yamldecode(file("${var.resources_path}/${file}"))
  ]
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

################################################################################
# STEP 5: CREATE S3 BUCKETS FOR EACH TEAM TO STORE THEIR INDIVIDUAL STATES
################################################################################

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  for_each = { for team in konnect_team.this : team.name => team }
  bucket = "kw.konnect.team.resources.${local.sanitized_team_names[each.value.name]}"

  tags = {
    Name        = "kw.konnect.team.resources.${local.sanitized_team_names[each.value.name]}"
  }
}

output "teams" {
  value = local.teams
}
