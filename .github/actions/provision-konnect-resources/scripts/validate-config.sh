#!/usr/bin/env bash
set -e

config=$(cat "$1" | yq -r .)

normalize_type() {
  case "$1" in
    "!!seq"|"array") echo "array" ;;
    "!!map"|"map"|"object") echo "map" ;;
    "!!str"|"str"|"string") echo "string" ;;
    "!!bool"|"bool"|"boolean") echo "bool" ;;
    "!!int"|"int"|"integer"|"number") echo "number" ;;
    ""|"null") echo "null" ;;
    *) echo "$1" ;;
  esac
}

# Validate metadata.type
metadata_type=$(echo "$config" | yq -r '.metadata.type')
if [ "$metadata_type" != "konnect.team.resources" ]; then
  echo "Invalid metadata.type: $metadata_type. Expected 'konnect.team.resources'"
  exit 1
fi

# Validate metadata.team is required
metadata_team=$(echo "$config" | yq -r '.metadata.team')
if [ -z "$metadata_team" ]; then
  echo "metadata.team is required"
  exit 1
fi

# Validate resources is an array
resources_type=$(normalize_type "$(echo "$config" | yq -r '.resources | type')")
if [ "$resources_type" != "array" ]; then
  echo "Invalid resources type: $resources_type. Expected 'array'"
  exit 1
fi

allowed_types=(
  "konnect.control_plane"
  "konnect.api_product"
  "konnect.api"
  "konnect.api_document"
  "konnect.api_specification"
  "konnect.api_implementation"
  "konnect.api_publication"
  "konnect.cloud_gateway_network"
  "konnect.cloud_gateway_configuration"
  "konnect.application_auth_strategy"
  "konnect.developer_portal"
  "konnect.portal_auth"
  "konnect.portal_custom_domain"
  "konnect.portal_team"
  "konnect.portal_customization"
  "konnect.portal_page"
  "konnect.portal_snippet"
  "konnect.portal_appearance"
  "konnect.portal_logo"
  "konnect.portal_favicon"
  "konnect.portal_product_version"
  "konnect.dashboard"
)
invalid_resources=""

for rtype in $(echo "$config" | yq -r '.resources[].type'); do
  if ! printf '%s\n' "${allowed_types[@]}" | grep -qx "$rtype"; then
    invalid_resources+="$rtype\n"
  fi

done

if [ -n "$invalid_resources" ]; then
  echo "Invalid resource types found:"
  echo -e "$invalid_resources"
  echo "Expected one of: ${allowed_types[*]}"
  exit 1
fi

dashboard_validation_errors=""
dashboards=$(echo "$config" | yq -c '.resources[] | select(.type == "konnect.dashboard")')

if [ -n "$dashboards" ]; then
  while IFS= read -r dashboard; do
    [ -z "$dashboard" ] && continue

    dashboard_name=$(echo "$dashboard" | yq -r '.name // ""')
    if [ -z "$dashboard_name" ] || [ "$dashboard_name" = "null" ]; then
      dashboard_validation_errors+="Dashboard resource is missing required field 'name'.\n"
    fi

    definition_type=$(normalize_type "$(echo "$dashboard" | yq -r '.definition | type' 2>/dev/null || echo "null")")
    if [ "$definition_type" != "map" ]; then
      dashboard_validation_errors+="Dashboard ${dashboard_name:-<unknown>} is missing required map field 'definition'.\n"
      continue
    fi

    tiles_type=$(normalize_type "$(echo "$dashboard" | yq -r '.definition.tiles | type' 2>/dev/null || echo "null")")
    if [ "$tiles_type" != "array" ]; then
      dashboard_validation_errors+="Dashboard ${dashboard_name:-<unknown>} definition must include 'tiles' array.\n"
    else
      tiles_count=$(echo "$dashboard" | yq -r '.definition.tiles | length' 2>/dev/null || echo "0")
      if [ "$tiles_count" -eq 0 ]; then
        dashboard_validation_errors+="Dashboard ${dashboard_name:-<unknown>} definition.tiles must include at least one tile.\n"
      fi
    fi
  done <<< "$dashboards"
fi

if [ -n "$dashboard_validation_errors" ]; then
  echo -e "$dashboard_validation_errors"
  exit 1
fi

echo "Config validation passed"
