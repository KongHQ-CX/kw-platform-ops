# Konnect Provisioning Terraform (GitHub Action)

This stack reads a YAML manifest (`var.config_file`) describing team resources and provisions Kong Konnect via the Terraform provider.

## New: Dev Portal modules and YAML mapping

The following resource types are supported via locals filtering and modules:

- konnect.developer_portal → module "developer_portals"
  - YAML fields → module inputs:
    - name (string) → name
    - description (string, optional) → description
    - labels (map[string], optional) → labels
- konnect.portal_auth → module "portal_auths"
  - YAML fields:
    - portal_name (string) → resolves portal_id from module.developer_portals[portal_name]
  - basic_auth_enabled (bool, optional)
  - oidc_auth_enabled (bool, optional)
  - saml_auth_enabled (bool, optional)
  - idp_mapping_enabled (bool, optional)
  - konnect_mapping_enabled (bool, optional)
  - oidc_team_mapping_enabled (bool, optional)
  - oidc_issuer (string, optional)
  - oidc_client_id (string, optional)
  - oidc_client_secret (string, optional)
  - oidc_scopes (list[string], optional)
- konnect.portal_custom_domain → module "portal_custom_domains"
  - YAML fields:
    - portal_name (string) → resolves portal_id
    - hostname (string)
    - enabled (bool, optional, default false)
- konnect.portal_team → module "portal_teams"
  - YAML fields:
    - portal_name (string) → resolves portal_id
    - name (string) → team name (must exist in Konnect)
- konnect.dashboard → module "dashboards" (provisions via `kong/konnect-beta`)
  - YAML fields:
    - name (string) → name
    - definition (map) → definition (pass-through, must satisfy schema tiles/preset_filters expectations)
    - labels (map[string], optional) → labels
    - slug (string, optional) → used as stable key for `for_each` but not sent to provider

Note: portal customization, page and snippet can be added later; initial thin slice focuses on the essentials.

## Minimal example

See `docs/examples/konnect/resources.portal-thin-slice.yaml` for a thin slice that creates a portal, enables basic auth, grants a team viewer access, and sets up a disabled custom domain placeholder.

## Running locally

Environment variables expected (can be exported or provided by your CI):

- KONNECT_TOKEN (also passed as TF_VAR_konnect_access_token)
- KONNECT_SERVER_URL (also passed as TF_VAR_konnect_server_url)
- TF_VAR_team_name, TF_VAR_konnect_region, TF_VAR_gh_workspace_path, TF_VAR_config_file

Provider pins to `kong/konnect` v3.1.0.

### Thin-slice plan/apply with TF_VAR env

You can pass sensitive values via environment variables instead of `local.auto.tfvars`:

Required env vars:

- `TF_VAR_konnect_access_token`
- `TF_VAR_konnect_server_url` (e.g., https://global.api.konghq.com or regional URL)
- `TF_VAR_team_name` (e.g., flight-operations)
- `TF_VAR_konnect_region` (e.g., eu)
- `TF_VAR_gh_workspace_path` (path to repo root)
- `TF_VAR_config_file` (path to YAML manifest)

Example thin slice uses `docs/examples/konnect/resources.portal-thin-slice.yaml`.

Tip: For a quick syntax-only check without a live token, you can run a plan with `-refresh=false`. This skips state refresh calls that require authentication. Use this only for dry runs; real applies require a valid token.
