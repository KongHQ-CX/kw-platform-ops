#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status


# Define variables with defaults
VAULT_ADDR="${1:-}"
VAULT_TOKEN="${2:-}"
GITHUB_ORG="${3:-}"
PKI_MOUNT_PATH="pki"
CERT_TTL="43800h" # 5 years
COMMON_NAME_ROOT="ca.kong.edu.local"
ROLE_NAME="kong"
ROLE_ALLOWED_DOMAINS="kong.edu.local"
CERT_TTL_ROLE="4380h"

# Interactive prompts only if not provided as arguments
if [ -z "$VAULT_ADDR" ]; then
  read -p "Vault address [http://127.0.0.1:8300]: " VAULT_ADDR_INPUT
  VAULT_ADDR="${VAULT_ADDR_INPUT:-http://127.0.0.1:8300}"
fi

if [ -z "$VAULT_TOKEN" ]; then
  read -p "Vault token [root]: " VAULT_TOKEN_INPUT
  VAULT_TOKEN="${VAULT_TOKEN_INPUT:-root}"
fi

if [ -z "$GITHUB_ORG" ]; then
  read -p "GitHub organization [null]: " GITHUB_ORG_INPUT
  GITHUB_ORG="${GITHUB_ORG_INPUT:-null}"
fi

read -p "PKI mount path [pki]: " PKI_MOUNT_PATH_INPUT
PKI_MOUNT_PATH="${PKI_MOUNT_PATH_INPUT:-$PKI_MOUNT_PATH}"

read -p "Root certificate TTL [43800h]: " CERT_TTL_INPUT
CERT_TTL="${CERT_TTL_INPUT:-$CERT_TTL}"

read -p "Root certificate common name [ca.kong.edu.local]: " COMMON_NAME_ROOT_INPUT
COMMON_NAME_ROOT="${COMMON_NAME_ROOT_INPUT:-$COMMON_NAME_ROOT}"

read -p "Role name [kong]: " ROLE_NAME_INPUT
ROLE_NAME="${ROLE_NAME_INPUT:-$ROLE_NAME}"

read -p "Role allowed domains [kong.edu.local]: " ROLE_ALLOWED_DOMAINS_INPUT
ROLE_ALLOWED_DOMAINS="${ROLE_ALLOWED_DOMAINS_INPUT:-$ROLE_ALLOWED_DOMAINS}"

read -p "Role certificate TTL [4380h]: " CERT_TTL_ROLE_INPUT
CERT_TTL_ROLE="${CERT_TTL_ROLE_INPUT:-$CERT_TTL_ROLE}"

export VAULT_ADDR
export VAULT_TOKEN


# Function to enable PKI secrets engine
enable_pki() {
    if ! vault secrets list | grep -q "^${PKI_MOUNT_PATH}/"; then
        vault secrets enable -path=${PKI_MOUNT_PATH} -max-lease-ttl="${CERT_TTL}" pki
        echo "PKI secrets engine enabled at ${PKI_MOUNT_PATH}."
    else
        echo "PKI secrets engine already enabled at ${PKI_MOUNT_PATH}."
    fi
}

# Function to configure the root certificate
configure_root_cert() {
    if ! vault read -field=certificate ${PKI_MOUNT_PATH}/cert/ca > /dev/null 2>&1; then
        vault write ${PKI_MOUNT_PATH}/root/generate/internal \
            common_name="${COMMON_NAME_ROOT}" \
            ttl="${CERT_TTL}"
        echo "Root certificate generated for ${COMMON_NAME_ROOT}."
    else
        echo "Root certificate already exists."
    fi
}

# Function to configure the CA certificate endpoint
configure_ca_endpoint() {
    vault write ${PKI_MOUNT_PATH}/config/urls \
        issuing_certificates="${VAULT_ADDR}/v1/${PKI_MOUNT_PATH}/ca" \
        crl_distribution_points="${VAULT_ADDR}/v1/${PKI_MOUNT_PATH}/crl"
    echo "CA certificate endpoint configured."
}

# Function to create a role for issuing certificates
create_role() {
    vault write ${PKI_MOUNT_PATH}/roles/${ROLE_NAME} \
        allowed_domains=${ROLE_ALLOWED_DOMAINS} \
        allow_subdomains=true \
        max_ttl="${CERT_TTL_ROLE}"
    echo "Role ${ROLE_NAME} created."
}

configure_vault_github_auth() {
    if ! vault auth list | grep -q "^github/"; then
        vault auth enable github
        echo "GitHub auth method enabled."
    else
        echo "GitHub auth method already enabled."
        return
    fi

    if [ "${GITHUB_ORG}" = "null" ]; then
        echo "No GitHub organization provided. Skipping GitHub auth org configuration."
        return
    fi

    vault write auth/github/config organization=${GITHUB_ORG}
    echo "GitHub organization configured: ${GITHUB_ORG}."
}

# Function to enable AppRole auth method
enable_approle_auth() {
    if ! vault auth list | grep -q "^approle/"; then
        vault auth enable approle
        echo "AppRole auth method enabled."
    else
        echo "AppRole auth method already enabled."
    fi
}

# Function to enable and configure JWT/OIDC auth backend for GitHub Actions
enable_github_actions_jwt_auth() {
    local JWT_PATH="github-actions"
    local OIDC_DISCOVERY_URL="https://token.actions.githubusercontent.com"
    local BOUND_AUDIENCE="https://github.com/${GITHUB_ORG}"

    if ! vault auth list | grep -q "^${JWT_PATH}/"; then
        vault auth enable -path="${JWT_PATH}" jwt
        echo "JWT/OIDC auth backend enabled at path '${JWT_PATH}'."
    else
        echo "JWT/OIDC auth backend already enabled at path '${JWT_PATH}'."
    fi

    vault write auth/${JWT_PATH}/config \
        oidc_discovery_url="${OIDC_DISCOVERY_URL}" \
        bound_issuer="${OIDC_DISCOVERY_URL}" \
        default_role="github-actions"

    vault write auth/${JWT_PATH}/role/github-actions \
        role_type="jwt" \
        user_claim="sub" \
        bound_audiences="${BOUND_AUDIENCE}" \
        token_policies="default" \
        token_ttl="1h" \
        token_max_ttl="4h"

    echo "JWT/OIDC auth backend for GitHub Actions configured."
}

# Main script execution
enable_pki
configure_root_cert
configure_ca_endpoint
create_role
configure_vault_github_auth
enable_approle_auth
enable_github_actions_jwt_auth
