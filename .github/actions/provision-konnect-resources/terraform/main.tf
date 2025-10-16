terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.1.0"
    }
    konnect-beta = {
      source  = "Kong/konnect-beta"
      version = "0.11.1"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.0.1"
    }
  }
}

locals {
  config                         = yamldecode(file(var.config_file))
  metadata                       = lookup(local.config, "metadata", {})
  resources                      = lookup(local.config, "resources", [])
  control_planes                 = [for resource in local.resources : resource if resource.type == "konnect.control_plane"]
  api_products                   = [for resource in local.resources : resource if resource.type == "konnect.api_product"]
  apis                           = [for resource in local.resources : resource if resource.type == "konnect.api"]
  api_documents                  = [for resource in local.resources : resource if resource.type == "konnect.api_document"]
  api_specifications             = [for resource in local.resources : resource if resource.type == "konnect.api_specification"]
  api_implementations            = [for resource in local.resources : resource if resource.type == "konnect.api_implementation"]
  api_publications               = [for resource in local.resources : resource if resource.type == "konnect.api_publication"]
  cloud_gateway_configurations   = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_configuration"]
  cloud_gateway_networks         = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_network"]
  cloud_gateway_custom_domains   = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_custom_domain"]
  cloud_gateway_private_dns      = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_private_dns"]
  cloud_gateway_transit_gateways = [for resource in local.resources : resource if resource.type == "konnect.cloud_gateway_transit_gateway"]
  application_auth_strategys     = [for resource in local.resources : resource if resource.type == "konnect.application_auth_strategy"]
  api_versions                   = [for resource in local.resources : resource if resource.type == "konnect.api_version"]
  developer_portals              = [for resource in local.resources : resource if resource.type == "konnect.developer_portal"]
  portal_auths                   = [for resource in local.resources : resource if resource.type == "konnect.portal_auth"]
  portal_custom_domains          = [for resource in local.resources : resource if resource.type == "konnect.portal_custom_domain"]
  portal_teams                   = [for resource in local.resources : resource if resource.type == "konnect.portal_team"]
  portal_customizations          = [for resource in local.resources : resource if resource.type == "konnect.portal_customization"]
  portal_pages                   = [for resource in local.resources : resource if resource.type == "konnect.portal_page"]
  portal_snippets                = [for resource in local.resources : resource if resource.type == "konnect.portal_snippet"]
  portal_appearances             = [for resource in local.resources : resource if resource.type == "konnect.portal_appearance"]
  portal_logos                   = [for resource in local.resources : resource if resource.type == "konnect.portal_logo"]
  portal_favicons                = [for resource in local.resources : resource if resource.type == "konnect.portal_favicon"]
  portal_product_versions        = [for resource in local.resources : resource if resource.type == "konnect.portal_product_version"]
  dashboards                     = [for resource in local.resources : resource if resource.type == "konnect.dashboard"]
  realms                         = [for resource in local.resources : resource if resource.type == "konnect.realm"]
  centralized_consumers          = [for resource in local.resources : resource if resource.type == "konnect.centralized_consumer"]
  centralized_consumer_keys      = [for resource in local.resources : resource if resource.type == "konnect.centralized_consumer_key"]

  # Organization Teams & Access
  teams      = [for resource in local.resources : resource if resource.type == "konnect.team"]
  team_roles = [for resource in local.resources : resource if resource.type == "konnect.team_role"]
  team_users = [for resource in local.resources : resource if resource.type == "konnect.team_user"]

  # System accounts
  system_accounts              = [for resource in local.resources : resource if resource.type == "konnect.system_account"]
  system_account_teams         = [for resource in local.resources : resource if resource.type == "konnect.system_account_team"]
  system_account_roles         = [for resource in local.resources : resource if resource.type == "konnect.system_account_role"]
  system_account_access_tokens = [for resource in local.resources : resource if resource.type == "konnect.system_account_access_token"]

  # Audit logs
  audit_log_destinations = [for resource in local.resources : resource if resource.type == "konnect.audit_log_destination"]
  audit_logs             = [for resource in local.resources : resource if resource.type == "konnect.audit_log"]

  # Integrations
  integration_instances                 = [for resource in local.resources : resource if resource.type == "konnect.integration_instance"]
  integration_instance_auth_configs     = [for resource in local.resources : resource if resource.type == "konnect.integration_instance_auth_config"]
  integration_instance_auth_credentials = [for resource in local.resources : resource if resource.type == "konnect.integration_instance_auth_credential"]
  days_to_hours                         = 365 * 24 // 1 year
  expiration_date                       = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
  short_names = {
    "Control Planes" = "cp",
    "API Products"   = "ap"
  }

  team_obj = var.konnect_access_token == "dummy" ? {
    id   = "dummy-team-id"
    name = var.team_name
    } : {
    id   = jsondecode(data.terracurl_request.fetch_team.response).data[0].id
    name = jsondecode(data.terracurl_request.fetch_team.response).data[0].name
  }
}

# Distinct list of emails to resolve to user IDs (only when non-dummy token)
locals {
  team_user_emails = distinct([
    for u in local.team_users : u.user_email
    if lookup(u, "user_email", null) != null && lookup(u, "user_id", null) == null
  ])
}

data "terracurl_request" "fetch_team" {
  name   = "products"
  url    = "https://global.api.konghq.com/v3/teams?filter[name][eq]=${var.team_name}"
  method = "GET"

  headers = {
    "Authorization" = "Bearer ${var.konnect_access_token}"
  }

  response_codes = [
    200
  ]

  max_retry      = 3
  retry_interval = 10
}

# Resolve Konnect user by email (skipped when using dummy token)
data "terracurl_request" "fetch_user_by_email" {
  for_each = var.konnect_access_token == "dummy" ? {} : { for e in local.team_user_emails : e => e }

  name   = "user_${each.key}"
  url    = "https://global.api.konghq.com/v3/users?filter[email][eq]=${each.key}"
  method = "GET"

  headers = {
    "Authorization" = "Bearer ${var.konnect_access_token}"
  }

  response_codes = [200]

  max_retry      = 3
  retry_interval = 10
}

module "control_planes" {
  source = "./modules/control_plane"

  for_each = { for cp in local.control_planes : cp.name => cp }

  name          = each.value.name
  description   = each.value.description
  cloud_gateway = lookup(each.value, "cloud_gateway", false)
  labels        = lookup(each.value, "labels", {})
  cluster_type  = lookup(each.value, "cluster_type", "CLUSTER_TYPE_HYBRID")
  auth_type     = lookup(each.value, "auth_type", "pki_client_certs")

  team = jsondecode(data.terracurl_request.fetch_team.response).data[0]
}

module "apis" {
  source = "./modules/api"

  for_each = { for api in local.apis : "${api.name}-${lookup(api, "version", "")}" => api }

  name         = each.value.name
  description  = lookup(each.value, "description", null)
  labels       = lookup(each.value, "labels", {})
  slug         = lookup(each.value, "slug", null)
  spec_content = try(file("${var.gh_workspace_path}/${each.value.spec_content.file}"), each.value.spec_content.content)
  api_version  = lookup(each.value, "version", null)
  portals      = lookup(each.value, "portals", [])
}

module "cloud_gateway_networks" {
  source = "./modules/cloud_gateway_network"

  for_each = { for net in local.cloud_gateway_networks : net.name => net }

  name                              = each.value.name
  region                            = lookup(each.value, "region", var.konnect_region)
  cidr_block                        = each.value.cidr_block
  availability_zones                = lookup(each.value, "availability_zones", [])
  cloud_gateway_provider_account_id = each.value.cloud_gateway_provider_account_id
}

module "cloud_gateway_configurations" {
  source = "./modules/cloud_gateway_configuration"

  for_each = { for cfg in local.cloud_gateway_configurations : cfg.control_plane_name => cfg }

  control_plane_id  = module.control_planes[each.value.control_plane_name].control_plane.id
  control_plane_geo = each.value.control_plane_geo
  dataplane_groups  = lookup(each.value, "dataplane_groups", [])
  config_version    = lookup(each.value, "version", "1.0.0")
}

################################################################################
# CLOUD GATEWAY EXTRAS: Custom Domains, Private DNS, Transit Gateways
################################################################################

module "cloud_gateway_custom_domains" {
  source = "./modules/cloud_gateway_custom_domain"

  # Stable composite key: control_plane_name:domain
  for_each = { for d in local.cloud_gateway_custom_domains : "${d.control_plane_name}:${d.domain}" => d }

  control_plane_id  = module.control_planes[each.value.control_plane_name].control_plane.id
  control_plane_geo = each.value.control_plane_geo
  domain            = each.value.domain
}

module "cloud_gateway_private_dns" {
  source = "./modules/cloud_gateway_private_dns"

  # Stable composite key: network_name:name (name optional; default "")
  for_each = { for p in local.cloud_gateway_private_dns : "${p.network_name}:${lookup(p, "name", "")}" => p }

  network_id = module.cloud_gateway_networks[each.value.network_name].id
  name       = lookup(each.value, "name", null)

  private_dns_attachment_config = lookup(each.value, "private_dns_attachment_config", null)
}

module "cloud_gateway_transit_gateways" {
  source = "./modules/cloud_gateway_transit_gateway"

  # Stable composite key: network_name:name (derive name from the first non-null provider block)
  for_each = {
    for t in local.cloud_gateway_transit_gateways :
    "${t.network_name}:${coalesce(
      try(t.aws_transit_gateway.name, null),
      try(t.aws_vpc_peering_gateway.name, null),
      try(t.azure_transit_gateway.name, null),
      try(t.gcp_vpc_peering_transit_gateway.name, null),
      ""
    )}" => t
  }

  network_id = module.cloud_gateway_networks[each.value.network_name].id

  aws_transit_gateway             = lookup(each.value, "aws_transit_gateway", null)
  aws_vpc_peering_gateway         = lookup(each.value, "aws_vpc_peering_gateway", null)
  azure_transit_gateway           = lookup(each.value, "azure_transit_gateway", null)
  gcp_vpc_peering_transit_gateway = lookup(each.value, "gcp_vpc_peering_transit_gateway", null)
}

################################################################################
# DEV PORTAL: Portals, Auth, Custom Domains, Teams
################################################################################

module "developer_portals" {
  source = "./modules/developer_portal"

  for_each = { for p in local.developer_portals : p.name => p }

  name                      = each.value.name
  description               = lookup(each.value, "description", null)
  display_name              = lookup(each.value, "display_name", null)
  labels                    = lookup(each.value, "labels", {})
  authentication_enabled    = lookup(each.value, "authentication_enabled", null)
  auto_approve_applications = lookup(each.value, "auto_approve_applications", null)
  auto_approve_developers   = lookup(each.value, "auto_approve_developers", null)
  default_api_visibility    = lookup(each.value, "default_api_visibility", null)
  default_application_auth_strategy_id = try(
    module.application_auth_strategy[each.value.default_application_auth_strategy_name].id,
    lookup(each.value, "default_application_auth_strategy_id", null)
  )
  default_page_visibility = lookup(each.value, "default_page_visibility", null)
  rbac_enabled            = lookup(each.value, "rbac_enabled", null)
  force_destroy           = lookup(each.value, "force_destroy", null)

  depends_on = [module.application_auth_strategy]
}



module "portal_custom_domains" {
  source = "./modules/portal_custom_domain"

  for_each = { for d in local.portal_custom_domains : "${d.portal_name}-${d.hostname}" => d }

  portal_id = module.developer_portals[each.value.portal_name].id
  hostname  = each.value.hostname
  enabled   = lookup(each.value, "enabled", false)
}

module "portal_teams" {
  source = "./modules/portal_team"

  for_each = { for t in local.portal_teams : "${t.portal_name}-${t.name}" => t }

  portal_id = module.developer_portals[each.value.portal_name].id
  name      = each.value.name
}

module "portal_auths" {
  source = "./modules/portal_auth"

  for_each = { for a in local.portal_auths : a.portal_name => a }

  portal_id                 = module.developer_portals[each.value.portal_name].id
  basic_auth_enabled        = lookup(each.value, "basic_auth_enabled", null)
  oidc_auth_enabled         = lookup(each.value, "oidc_auth_enabled", null)
  saml_auth_enabled         = lookup(each.value, "saml_auth_enabled", null)
  idp_mapping_enabled       = lookup(each.value, "idp_mapping_enabled", null)
  konnect_mapping_enabled   = lookup(each.value, "konnect_mapping_enabled", null)
  oidc_team_mapping_enabled = lookup(each.value, "oidc_team_mapping_enabled", null)
  oidc_issuer               = lookup(each.value, "oidc_issuer", null)
  oidc_client_id            = lookup(each.value, "oidc_client_id", null)
  oidc_client_secret        = lookup(each.value, "oidc_client_secret", null)
  oidc_scopes               = lookup(each.value, "oidc_scopes", [])
}

################################################################################
# DEV PORTAL CONTENT & APPEARANCE: Customization, Pages, Snippets, Appearance,
# Logos, Favicons, Product Versions
################################################################################

module "portal_customizations" {
  source = "./modules/portal_customization"

  for_each = { for c in local.portal_customizations : c.portal_name => c }

  portal_id     = module.developer_portals[each.value.portal_name].id
  css           = lookup(each.value, "css", null)
  layout        = lookup(each.value, "layout", null)
  robots        = lookup(each.value, "robots", null)
  menu          = lookup(each.value, "menu", null)
  spec_renderer = lookup(each.value, "spec_renderer", null)
  theme         = lookup(each.value, "theme", null)
}

module "portal_pages" {
  source = "./modules/portal_page"

  for_each = { for p in local.portal_pages : "${p.portal_name}:${p.slug}" => p }

  portal_id      = module.developer_portals[each.value.portal_name].id
  slug           = each.value.slug
  content        = each.value.content
  title          = lookup(each.value, "title", null)
  description    = lookup(each.value, "description", null)
  parent_page_id = lookup(each.value, "parent_page_id", null)
  status         = lookup(each.value, "status", null)
  visibility     = lookup(each.value, "visibility", null)
}

module "portal_snippets" {
  source = "./modules/portal_snippet"

  for_each = { for s in local.portal_snippets : "${s.portal_name}:${s.name}" => s }

  portal_id   = module.developer_portals[each.value.portal_name].id
  name        = each.value.name
  content     = each.value.content
  title       = lookup(each.value, "title", null)
  description = lookup(each.value, "description", null)
  status      = lookup(each.value, "status", null)
  visibility  = lookup(each.value, "visibility", null)
}

module "portal_appearances" {
  source = "./modules/portal_appearance"

  for_each = { for a in local.portal_appearances : a.portal_name => a }

  portal_id        = module.developer_portals[each.value.portal_name].id
  theme_name       = lookup(each.value, "theme_name", null)
  use_custom_fonts = lookup(each.value, "use_custom_fonts", null)
}

module "portal_logos" {
  source = "./modules/portal_logo"

  for_each = { for l in local.portal_logos : l.portal_name => l }

  portal_id = module.developer_portals[each.value.portal_name].id
  data      = each.value.data
}

module "portal_favicons" {
  source = "./modules/portal_favicon"

  for_each = { for f in local.portal_favicons : f.portal_name => f }

  portal_id = module.developer_portals[each.value.portal_name].id
  data      = each.value.data
}

module "portal_product_versions" {
  source = "./modules/portal_product_version"

  for_each = { for v in local.portal_product_versions : "${v.portal_name}:${v.product_version_id}" => v }

  portal_id                        = module.developer_portals[each.value.portal_name].id
  product_version_id               = each.value.product_version_id
  publish_status                   = each.value.publish_status
  application_registration_enabled = each.value.application_registration_enabled
  auto_approve_registration        = each.value.auto_approve_registration
  deprecated                       = each.value.deprecated
  auth_strategy_ids                = each.value.auth_strategy_ids
  notify_developers                = lookup(each.value, "notify_developers", null)
}

module "dashboards" {
  source = "./modules/dashboard"
  providers = {
    konnect-beta = konnect-beta
  }

  for_each = {
    for dashboard in local.dashboards :
    coalesce(lookup(dashboard, "slug", null), dashboard.name) => dashboard
  }

  name       = each.value.name
  labels     = lookup(each.value, "labels", {})
  definition = each.value.definition

  depends_on = [module.developer_portals]
}

################################################################################
# REALMS AND CENTRALIZED CONSUMERS
################################################################################

module "realm" {
  source = "./modules/realm"

  # Stable key: realm name
  for_each = { for r in local.realms : r.name => r }

  name                     = each.value.name
  allow_all_control_planes = lookup(each.value, "allow_all_control_planes", null)
  allowed_control_planes   = lookup(each.value, "allowed_control_planes", [])
  consumer_groups          = lookup(each.value, "consumer_groups", [])
  ttl                      = lookup(each.value, "ttl", null)
  negative_ttl             = lookup(each.value, "negative_ttl", null)
  force_destroy            = lookup(each.value, "force_destroy", null)
}

module "centralized_consumer" {
  source = "./modules/centralized_consumer"

  # Stable key: realm_name:username
  for_each = { for c in local.centralized_consumers : "${c.realm_name}:${c.username}" => c }

  realm_id        = module.realm[each.value.realm_name].id
  username        = each.value.username
  custom_id       = lookup(each.value, "custom_id", null)
  consumer_type   = lookup(each.value, "consumer_type", null)
  consumer_groups = lookup(each.value, "consumer_groups", [])
  tags            = lookup(each.value, "tags", [])
}

module "centralized_consumer_key" {
  source = "./modules/centralized_consumer_key"

  # Stable key: realm_name:consumer_username:name|key_type
  for_each = {
    for k in local.centralized_consumer_keys :
    "${k.realm_name}:${k.consumer_username}:${lookup(k, "name", lookup(k, "key_type", "legacy"))}" => k
  }

  realm_id    = module.realm[each.value.realm_name].id
  consumer_id = module.centralized_consumer["${each.value.realm_name}:${each.value.consumer_username}"].id
  key_type    = lookup(each.value, "key_type", null)
  secret      = lookup(each.value, "secret", null)
  tags        = lookup(each.value, "tags", [])
}

################################################################################
# AUDIT LOG DESTINATIONS & LOGS
################################################################################

module "audit_log_destinations" {
  source = "./modules/audit_log_destination"

  # Stable key: name
  for_each = { for d in local.audit_log_destinations : d.name => d }

  name                  = each.value.name
  endpoint              = each.value.endpoint
  authorization         = lookup(each.value, "authorization", null)
  log_format            = lookup(each.value, "log_format", null)
  skip_ssl_verification = lookup(each.value, "skip_ssl_verification", null)
}

module "audit_logs" {
  source = "./modules/audit_log"

  # Stable key: endpoint or name in YAML if provided; fall back to endpoint
  for_each = { for l in local.audit_logs : lookup(l, "name", lookup(l, "endpoint", "default")) => l }

  endpoint              = lookup(each.value, "endpoint", null)
  authorization         = lookup(each.value, "authorization", null)
  enabled               = lookup(each.value, "enabled", null)
  log_format            = lookup(each.value, "log_format", null)
  skip_ssl_verification = lookup(each.value, "skip_ssl_verification", null)
}

################################################################################
# SYSTEM ACCOUNTS: Accounts, Team Assignment, Roles, Access Tokens
################################################################################

module "system_account" {
  source = "./modules/system_account"

  # Stable key: account name
  for_each = { for a in local.system_accounts : a.name => a }

  name            = each.value.name
  description     = lookup(each.value, "description", null)
  konnect_managed = lookup(each.value, "konnect_managed", false)
}

module "system_account_team" {
  source = "./modules/system_account_team"

  # Stable key: account_name:team_name (team_name optional; default to metadata/local team)
  for_each = {
    for t in local.system_account_teams :
    "${t.account_name}:${lookup(t, "team_name", local.team_obj.name)}" => t
  }

  account_id = module.system_account[each.value.account_name].id
  team_id    = local.team_obj.id
}

module "system_account_role" {
  source = "./modules/system_account_role"

  # Stable key: account_name:entity_type_name:role_name:entity_id:entity_region
  for_each = {
    for r in local.system_account_roles :
    "${r.account_name}:${r.entity_type_name}:${r.role_name}:${lookup(r, "entity_id", "*")}:${lookup(r, "entity_region", var.konnect_region)}" => r
  }

  account_id       = module.system_account[each.value.account_name].id
  entity_type_name = lookup(each.value, "entity_type_name", null)
  role_name        = lookup(each.value, "role_name", null)
  entity_id        = lookup(each.value, "entity_id", null)
  entity_region    = lookup(each.value, "entity_region", var.konnect_region)
}

module "system_account_access_token" {
  source = "./modules/system_account_access_token"

  # Stable key: account_name:token_name
  for_each = {
    for t in local.system_account_access_tokens :
    "${t.account_name}:${lookup(t, "name", "default")}" => t
  }

  account_id = module.system_account[each.value.account_name].id
  name       = lookup(each.value, "name", null)
  expires_at = lookup(each.value, "expires_at", null)
}

################################################################################
# ORGANIZATION TEAMS AND ROLES
################################################################################

module "teams" {
  source = "./modules/team"

  # Stable key: team name
  for_each = { for t in local.teams : t.name => t }

  name        = each.value.name
  description = lookup(each.value, "description", null)
  labels      = lookup(each.value, "labels", {})
}

module "team_roles" {
  source = "./modules/team_role"

  # Stable key: team_name:entity_type_name:role_name:entity_id:entity_region
  for_each = {
    for r in local.team_roles :
    "${r.team_name}:${r.entity_type_name}:${r.role_name}:${lookup(r, "entity_id", "*")}:${lookup(r, "entity_region", var.konnect_region)}" => r
  }

  team_id          = module.teams[each.value.team_name].id
  entity_type_name = lookup(each.value, "entity_type_name", null)
  role_name        = lookup(each.value, "role_name", null)
  entity_id        = lookup(each.value, "entity_id", null)
  entity_region    = lookup(each.value, "entity_region", var.konnect_region)
}

module "team_users" {
  source = "./modules/team_user"

  # Stable key: team_name:user_email|user_id
  for_each = {
    for u in local.team_users :
    "${u.team_name}:${lookup(u, "user_email", lookup(u, "user_id", "unknown"))}" => u
  }

  team_id = module.teams[each.value.team_name].id
  # Prefer explicit user_id; otherwise resolve by email when not dummy, or use a placeholder in dummy mode
  user_id = coalesce(
    lookup(each.value, "user_id", null),
    var.konnect_access_token == "dummy" ? "dummy-user-id" : jsondecode(data.terracurl_request.fetch_user_by_email[each.value.user_email].response).data[0].id
  )
}

# ------------------------------------------------------------------------------
# INTEGRATIONS: Instances, Auth Configs, Credentials
# ------------------------------------------------------------------------------

module "integration_instances" {
  source = "./modules/integration_instance"

  # Stable key: org_id:name (org_id optional)
  for_each = { for i in local.integration_instances : "${lookup(i, "org_id", "")}:${i.name}" => i }

  name             = each.value.name
  display_name     = each.value.display_name
  integration_name = each.value.integration_name
  description      = lookup(each.value, "description", null)
  # Accept object or string in YAML: prefer jsonencode if object provided
  config = try(jsonencode(each.value.config), each.value.config)
}

module "integration_instance_auth_configs" {
  source = "./modules/integration_instance_auth_config"

  # Stable key: org_id:instance_name:strategy (strategy optional, default "oauth")
  for_each = {
    for c in local.integration_instance_auth_configs :
    "${lookup(c, "org_id", "")}:${c.instance_name}:${lookup(c, "strategy", "oauth")}" => c
  }

  integration_instance_id = module.integration_instances["${lookup(each.value, "org_id", "")}:${each.value.instance_name}"].id

  oauth_config = lookup(each.value, "oauth_config", null)
}

module "integration_instance_auth_credentials" {
  source = "./modules/integration_instance_auth_credential"

  # Stable key: org_id:instance_name:name
  for_each = {
    for c in local.integration_instance_auth_credentials :
    "${lookup(c, "org_id", "")}:${c.instance_name}:${lookup(c, "name", "")}" => c
  }

  integration_instance_id = module.integration_instances["${lookup(each.value, "org_id", "")}:${each.value.instance_name}"].id
  multi_key_auth          = lookup(each.value, "multi_key_auth", null)
}

# Application Auth Strategies (for Portal Product Versions, Publications, etc.)
module "application_auth_strategy" {
  source = "./modules/application_auth_strategy"

  for_each = { for s in local.application_auth_strategys : s.name => s }

  name               = each.value.name
  display_name       = lookup(each.value, "display_name", null)
  labels             = lookup(each.value, "labels", {})
  strategy_type      = lookup(each.value, "strategy_type", "key_auth")
  key_auth_key_names = lookup(lookup(each.value, "configs", {}), "key_auth", {}) != {} ? lookup(lookup(each.value.configs, "key_auth", {}), "key_names", []) : lookup(each.value, "key_auth_key_names", [])

  oidc_dcr_provider_id       = lookup(each.value, "dcr_provider_id", null)
  oidc_additional_properties = lookup(lookup(lookup(each.value, "configs", {}), "openid_connect", {}), "additional_properties", null)
  oidc_auth_methods          = lookup(lookup(lookup(each.value, "configs", {}), "openid_connect", {}), "auth_methods", [])
  oidc_credential_claim      = lookup(lookup(lookup(each.value, "configs", {}), "openid_connect", {}), "credential_claim", [])
  oidc_issuer                = lookup(lookup(lookup(each.value, "configs", {}), "openid_connect", {}), "issuer", null)
  oidc_scopes                = lookup(lookup(lookup(each.value, "configs", {}), "openid_connect", {}), "scopes", [])
}

# API Versions
module "api_versions" {
  source = "./modules/api_version"

  for_each = { for v in local.api_versions : "${v.api_id}:${lookup(v, "version", "")}" => v }

  api_id       = each.value.api_id
  api_version  = lookup(each.value, "version", null)
  spec_content = try(file("${var.gh_workspace_path}/${each.value.spec_content.file}"), each.value.spec_content.content)
}

# module "api_documents" {
#   source = "./modules/api_document"

#   for_each = { for doc in local.api_documents : "${doc.api_name}-${doc.slug}" => doc }

#   api_id             = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   content            = each.value.content
#   labels             = lookup(each.value, "labels", {})
#   parent_document_id = lookup(each.value, "parent_document_id", null)
#   slug               = each.value.slug
#   status             = lookup(each.value, "status", "unpublished")
#   title              = lookup(each.value, "title", null)
# }

# module "api_specifications" {
#   source = "./modules/api_specification"

#   for_each = { for spec in local.api_specifications : "${spec.api_name}-${lookup(spec, "api_version", "")}" => spec }

#   api_id  = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   content = each.value.content
#   type    = lookup(each.value, "spec_type", null)
# }

# module "api_implementations" {
#   source = "./modules/api_implementation"

#   for_each = { for impl in local.api_implementations : "${impl.api_name}-${impl.service.control_plane_name}" => impl }

#   api_id = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
#   service = {
#     control_plane_id = module.control_planes[each.value.service.control_plane_name].control_plane.id
#     id               = each.value.service.id
#   }
# }

module "api_publications" {
  source = "./modules/api_publication"

  for_each = { for pub in local.api_publications : "${pub.api_name}-${pub.portal_name}" => pub }

  api_id                     = module.apis["${each.value.api_name}-${lookup(each.value, "api_version", "")}"].id
  portal_id                  = module.developer_portals[each.value.portal_name].id
  auth_strategy_ids          = lookup(each.value, "auth_strategy_ids", null) != null ? [for name in each.value.auth_strategy_ids : module.application_auth_strategy[name].id] : null
  auto_approve_registrations = lookup(each.value, "auto_approve_registrations", null)
  visibility                 = lookup(each.value, "visibility", "private")
}
