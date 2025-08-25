terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

locals {
  config_files = fileset("${var.resources_path}", "*.yaml")
  
  # Create teams with filename as stable key
  teams_by_file = {
    for file in local.config_files : 
    basename(file, ".yaml") => yamldecode(file("${var.resources_path}/${file}"))
  }
  
  # Keep your existing teams list for compatibility
  teams = values(local.teams_by_file)
  
  sanitized_team_names = { 
    for key, team in local.teams_by_file : 
    key => replace(lower(team.name), " ", "-") 
  }
}


################################################################################
# STEP 1: CREATE THE KONNECT TEAMS
################################################################################

resource "konnect_team" "this" {
  for_each = local.teams_by_file

  description = lookup(each.value, "description", null)
  labels = merge(lookup(each.value, "labels", {}), {
    "generated_by" = "terraform"
  })
  name = each.value.name
}

################################################################################
# STEP 2: CREATE THE KONNECT SYSTEM ACCOUNTS FOR EACH TEAM
################################################################################
module "system-account" {
  for_each = konnect_team.this

  source = "./modules/system-account"

  team_name         = local.sanitized_team_names[each.key]
  team_entitlements = try(local.teams_by_file[each.key].entitlements, [])
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
  for_each = konnect_team.this

  source = "./modules/vault"

  team_name                  = local.sanitized_team_names[each.key]
  system_account_secret_path = "system-accounts/sa-${local.sanitized_team_names[each.key]}"
  system_account_token       = module.system-account[each.key].system_account_token
}


################################################################################
# STEP 5: CREATE S3 BUCKETS FOR EACH TEAM TO STORE THEIR INDIVIDUAL STATES
################################################################################

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  for_each = konnect_team.this
  bucket = "kw.konnect.team.resources.${local.sanitized_team_names[each.key]}"

  tags = {
    Name = "kw.konnect.team.resources.${local.sanitized_team_names[each.key]}"
  }
}

output "teams" {
  value = local.teams
}
