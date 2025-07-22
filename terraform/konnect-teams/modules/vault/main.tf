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

# Single policy with full access for both reading secrets and managing secrets
resource "vault_policy" "this" {
  name = "${vault_mount.this.path}-policy"

  policy = <<EOT
# Full access to manage secrets in the team's mount
path "${vault_mount.this.path}/data/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "${vault_mount.this.path}/metadata/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Delete specific secret versions
path "${vault_mount.this.path}/delete/*" {
  capabilities = ["update"]
}

# Undelete secret versions
path "${vault_mount.this.path}/undelete/*" {
  capabilities = ["update"]
}

# Destroy secret versions permanently
path "${vault_mount.this.path}/destroy/*" {
  capabilities = ["update"]
}

# List secrets at the mount root
path "${vault_mount.this.path}/metadata" {
  capabilities = ["list"]
}

# Allow creating child tokens (needed for vault-action)
path "auth/token/create" {
  capabilities = ["create", "update"]
}

# Allow token renewal and revocation
path "auth/token/renew" {
  capabilities = ["update"]
}

path "auth/token/revoke" {
  capabilities = ["update"]
}

# Allow reading token information
path "auth/token/lookup-self" {
  capabilities = ["read"]
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
  
  # TTL suitable for Terraform operations
  token_ttl         = 1800  # 30 minutes
  token_max_ttl     = 3600  # 1 hour
  token_num_uses    = 0     # Unlimited uses
}

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
