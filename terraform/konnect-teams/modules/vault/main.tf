terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

data "vault_auth_backend" "this" {
  path = "github-actions"
}

# Create a team vault mount for the KV version 2 secret engine
resource "vault_mount" "this" {
  path        = "${var.team_name}-kv"
  type        = "kv"
  options     = { version = "2" }
  description = "Vault mount for the ${var.team_name} team"
}

# Create team vault policy
resource "vault_policy" "this" {
  name = "${vault_mount.this.path}-policy"

  policy = <<EOT
path "${vault_mount.this.path}/data/*" {
  capabilities = ["read"]
}

path "${vault_mount.this.path}/metadata/*" {
  capabilities = ["read"]
}

# Optional: Allow listing secrets
path "${vault_mount.this.path}/metadata" {
  capabilities = ["list"]
}

EOT
}

# 3. Create JWT role that maps your specific repository to the policy
resource "vault_jwt_auth_backend_role" "github_repo" {
  backend         = data.vault_auth_backend.this.path
  role_name       = "${var.team_name}-gh-repo-role"
  token_policies  = [vault_policy.this.name]

  # Verify the token audience matches your org
  bound_audiences = ["https://github.com/${var.github_organization}"]
  
  # CRITICAL: This restricts access to your specific repository
  bound_claims = {
    repository = "${var.github_organization}/kw-${var.team_name}-repo"
    # Optional: restrict to specific branch
    # ref = "refs/heads/main"
  }
  
  # Map the 'sub' claim to the Vault user identity
  user_claim    = "sub"
  role_type     = "jwt"
  
  # Short-lived tokens (GitHub tokens are valid for ~10 minutes anyway)
  token_ttl     = 300  # 5 minutes
  token_max_ttl = 600  # 10 minutes
}
# # Map policy to team
# resource "vault_github_team" "this" {
#   backend  = data.vault_auth_backend.this.id
#   team     = var.team_name
#   policies = ["${vault_policy.this.name}"]
# }

# Store the access token in the KV
resource "vault_kv_secret_v2" "this" {

  mount               = vault_mount.this.path
  name                = var.system_account_secret_path
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = var.system_account_token
    }
  )
  custom_metadata {
    max_versions = 5
  }
}
