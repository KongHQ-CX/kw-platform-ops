#!/usr/bin/env bash
set -e

config=$(cat "$1" | yq -r .)

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
resources_type=$(echo "$config" | yq -r '.resources | type')
if [ "$resources_type" != "!!seq" ]; then
  echo "Invalid resources type: $resources_type. Expected '!!seq' (array)"
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

echo "Config validation passed"
