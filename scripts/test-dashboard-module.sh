#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/test-dashboard-module.sh [options] [-- terraform-plan-flags]

Options:
  -m, --manifest <path>   Path to the Konnect manifest YAML (default: konnect/dashboards/dashboard-config.yaml)
  -t, --team-name <name>  Override team name instead of reading from the manifest
  -r, --region <code>     Override Konnect region (default: manifest metadata.region or "eu")
      --full-plan         Plan the entire stack instead of targeting module.dashboards
  -h, --help              Show this help

Extra arguments after "--" are passed directly to "terraform plan".
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_FILE="${ROOT_DIR}/act.secrets"
VARS_FILE="${ROOT_DIR}/.vars"
TERRAFORM_DIR="${ROOT_DIR}/.github/actions/provision-konnect-resources/terraform"

MANIFEST="${ROOT_DIR}/konnect/dashboards/dashboard-config.yaml"
TEAM_NAME=""
REGION_OVERRIDE=""
TARGET_ONLY=true
PLAN_ARGS=()

abs_path() {
  local input=$1
  if [[ "${input}" == /* ]]; then
    printf '%s\n' "$(cd "$(dirname "${input}")" && pwd)/$(basename "${input}")"
  else
    printf '%s\n' "$(cd "${ROOT_DIR}" && cd "$(dirname "${input}")" && pwd)/$(basename "${input}")"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--manifest)
      [[ $# -gt 1 ]] || { echo "Missing value for $1" >&2; exit 1; }
      MANIFEST="$(abs_path "$2")"
      shift 2
      ;;
    -t|--team-name)
      [[ $# -gt 1 ]] || { echo "Missing value for $1" >&2; exit 1; }
      TEAM_NAME="$2"
      shift 2
      ;;
    -r|--region)
      [[ $# -gt 1 ]] || { echo "Missing value for $1" >&2; exit 1; }
      REGION_OVERRIDE="$2"
      shift 2
      ;;
    --full-plan)
      TARGET_ONLY=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      PLAN_ARGS+=("$@")
      break
      ;;
    *)
      PLAN_ARGS+=("$1")
      shift
      ;;
  esac
done

[[ -f "${MANIFEST}" ]] || { echo "Manifest not found: ${MANIFEST}" >&2; exit 1; }
[[ -f "${SECRETS_FILE}" ]] || { echo "Secrets file missing: ${SECRETS_FILE}" >&2; exit 1; }
[[ -f "${VARS_FILE}" ]] || { echo "Vars file missing: ${VARS_FILE}" >&2; exit 1; }

lookup_kv() {
  local file=$1 key=$2
  if [[ -f "$file" ]]; then
    local line
    line=$(grep -E "^${key}=" "$file" | tail -n1 || true)
    if [[ -n "$line" ]]; then
      echo "${line#*=}"
    fi
  fi
}

export VAULT_ADDR="$(lookup_kv "${VARS_FILE}" "VAULT_ADDR")"
export VAULT_TOKEN="$(lookup_kv "${SECRETS_FILE}" "VAULT_TOKEN")"

export AWS_ENDPOINT_URL="$(lookup_kv "${VARS_FILE}" "AWS_ENDPOINT_URL")"
export AWS_ACCESS_KEY_ID="$(lookup_kv "${SECRETS_FILE}" "AWS_ACCESS_KEY_ID")"
export AWS_SECRET_ACCESS_KEY="$(lookup_kv "${SECRETS_FILE}" "AWS_SECRET_ACCESS_KEY")"
export AWS_SESSION_TOKEN="$(lookup_kv "${SECRETS_FILE}" "AWS_SESSION_TOKEN")"
export AWS_REGION="$(lookup_kv "${VARS_FILE}" "AWS_REGION")"

KONNECT_TOKEN="$(lookup_kv "${SECRETS_FILE}" "KONNECT_TOKEN")"
KONNECT_SERVER_URL="$(lookup_kv "${VARS_FILE}" "KONNECT_SERVER_URL")"
KONNECT_REGION="$(lookup_kv "${VARS_FILE}" "KONNECT_REGION")"

if [[ -z "${TEAM_NAME}" ]] && command -v yq >/dev/null 2>&1; then
  TEAM_NAME="$(yq -r '.metadata.team // ""' "${MANIFEST}")"
fi
if [[ -z "${TEAM_NAME}" ]]; then
  TEAM_NAME="dashboard-ops"
fi

if [[ -z "${REGION_OVERRIDE}" ]] && command -v yq >/dev/null 2>&1; then
  REGION_OVERRIDE="$(yq -r '.metadata.region // ""' "${MANIFEST}")"
fi
if [[ -n "${REGION_OVERRIDE}" ]]; then
  KONNECT_REGION="${REGION_OVERRIDE}"
fi
if [[ -z "${KONNECT_REGION}" ]]; then
  KONNECT_REGION="eu"
fi

[[ -n "${KONNECT_TOKEN}" ]] || { echo "KONNECT_TOKEN not found in ${SECRETS_FILE}" >&2; exit 1; }
[[ -n "${TEAM_NAME}" ]] || { echo "Unable to determine team name" >&2; exit 1; }

export TF_VAR_konnect_server_url="${KONNECT_SERVER_URL:-https://global.api.konghq.com}"
export TF_VAR_konnect_access_token="${KONNECT_TOKEN}"
export TF_VAR_konnect_region="${KONNECT_REGION}"
export TF_VAR_config_file="${MANIFEST}"
export TF_VAR_gh_workspace_path="${ROOT_DIR}"
export TF_VAR_team_name="${TEAM_NAME}"

TF_TMP_DIR="$(mktemp -d)"
export TF_DATA_DIR="${TF_TMP_DIR}"
RUN_DIR="$(mktemp -d)"
trap 'rm -rf "${TF_TMP_DIR}" "${RUN_DIR}"' EXIT

rsync -a --delete --exclude ".terraform" "${TERRAFORM_DIR}/" "${RUN_DIR}/"
rm -f "${RUN_DIR}/backend.tf"

echo "Using manifest: ${TF_VAR_config_file}"
echo "Team name: ${TF_VAR_team_name}"
echo "Konnect region: ${TF_VAR_konnect_region}"
echo "AWS region: ${AWS_REGION:-<unset>}"
[[ -n "${AWS_ENDPOINT_URL}" ]] && echo "AWS endpoint: ${AWS_ENDPOINT_URL}"

cd "${RUN_DIR}"
echo "Initializing Terraform (backend disabled)..."
terraform init -backend=false

if [[ "${TF_VAR_konnect_access_token}" == "dummy" ]]; then
  REFRESH=false
else
  REFRESH=true
fi

PLAN_FLAGS=("-refresh=${REFRESH}")
if [[ "${TARGET_ONLY}" == true ]]; then
  PLAN_FLAGS+=("-target=module.dashboards")
fi

if (( ${#PLAN_ARGS[@]} )); then
  terraform plan "${PLAN_FLAGS[@]}" "${PLAN_ARGS[@]}"
else
  terraform plan "${PLAN_FLAGS[@]}"
fi
