#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALIDATOR="$ROOT_DIR/.github/actions/provision-konnect-resources/scripts/validate-config.sh"

if ! command -v yq >/dev/null 2>&1 && [ -x "$HOME/Library/Python/3.9/bin/yq" ]; then
  export PATH="$HOME/Library/Python/3.9/bin:$PATH"
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "yq command not found. Install yq to run validator tests." >&2
  exit 1
fi

pass_cases=(
  "$ROOT_DIR/konnect/dashboards/dashboard-config.yaml"
  "$ROOT_DIR/konnect/developer-portal/config.yaml"
)

fail_cases=(
  "$ROOT_DIR/test/provisioning/fixtures/dashboard-missing-definition.yaml"
)

exit_code=0

echo "Running validator happy-path checks..."
for manifest in "${pass_cases[@]}"; do
  if bash "$VALIDATOR" "$manifest" >/dev/null 2>&1; then
    echo "  ✔ $(basename "$manifest") passes"
  else
    echo "  ✘ $(basename "$manifest") unexpectedly failed"
    exit_code=1
  fi
done

echo "Running validator negative checks..."
for manifest in "${fail_cases[@]}"; do
  if bash "$VALIDATOR" "$manifest" >/dev/null 2>&1; then
    echo "  ✘ $(basename "$manifest") should have failed but passed"
    exit_code=1
  else
    echo "  ✔ $(basename "$manifest") correctly failed"
  fi
done

exit $exit_code
